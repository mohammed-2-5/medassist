import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/services/backup/backup_crypto.dart';
import 'package:med_assist/services/backup/backup_exception.dart';
import 'package:med_assist/services/backup/backup_import_result.dart';
import 'package:med_assist/services/backup/backup_serializer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for backing up and restoring app data.
///
/// Supports optional AES-GCM encryption via [BackupCrypto]. When a non-empty
/// passphrase is supplied to [createBackup] / [shareBackup], the backup is
/// written as an encrypted wrapper; otherwise plain JSON is written and stays
/// compatible with older unencrypted backups.
class BackupService {
  BackupService(this._database);

  final AppDatabase _database;

  /// Export all data to a JSON file. Returns the file path of the backup.
  /// When [passphrase] is non-empty, the payload is AES-GCM encrypted.
  Future<String> createBackup({String? passphrase}) async {
    try {
      final plaintext = await _buildBackupJson();
      final isEncrypted = passphrase != null && passphrase.isNotEmpty;
      final output = isEncrypted
          ? await BackupCrypto.encryptJson(
              plaintext: plaintext,
              passphrase: passphrase,
            )
          : plaintext;

      final directory = await getApplicationDocumentsDirectory();
      final timestamp =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final suffix = isEncrypted ? '_enc' : '';
      final filePath =
          '${directory.path}/medassist_backup_$timestamp$suffix.json';

      await File(filePath).writeAsString(output);
      return filePath;
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException('Failed to create backup: $e');
    }
  }

  /// Share a backup file via the system share sheet.
  Future<void> shareBackup({String? passphrase}) async {
    try {
      final filePath = await createBackup(passphrase: passphrase);
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'MedAssist Backup',
        text: 'MedAssist medication data backup',
      );
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException('Failed to share backup: $e');
    }
  }

  /// Import data from a backup JSON file.
  ///
  /// If [filePath] is null, a file picker is shown. If the target is
  /// encrypted and [passphrase] is null/empty, throws
  /// [BackupEncryptedException] so the caller can prompt the user and retry.
  Future<BackupImportResult> restoreBackup({
    String? filePath,
    String? passphrase,
  }) async {
    final backupFilePath = filePath ?? await _pickBackupFile();

    final file = File(backupFilePath);
    if (!await file.exists()) {
      throw BackupException('Backup file not found');
    }

    final rawJson =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    final backupData = await _unwrap(
      rawJson: rawJson,
      filePath: backupFilePath,
      passphrase: passphrase,
    );

    try {
      _validateBackupFormat(backupData);

      final data = backupData['data'] as Map<String, dynamic>;
      final medications = (data['medications'] as List<dynamic>)
          .map(
            (j) => BackupSerializer.medicationFromJson(
              j as Map<String, dynamic>,
            ),
          )
          .toList();
      final doseHistory = (data['doseHistory'] as List<dynamic>)
          .map(
            (j) => BackupSerializer.doseHistoryFromJson(
              j as Map<String, dynamic>,
            ),
          )
          .toList();
      final snoozeHistory = (data['snoozeHistory'] as List<dynamic>)
          .map(
            (j) => BackupSerializer.snoozeHistoryFromJson(
              j as Map<String, dynamic>,
            ),
          )
          .toList();
      final stockHistory = (data['stockHistory'] as List<dynamic>)
          .map(
            (j) => BackupSerializer.stockHistoryFromJson(
              j as Map<String, dynamic>,
            ),
          )
          .toList();

      await _database.restoreAllData(
        meds: medications,
        doses: doseHistory,
        snoozes: snoozeHistory,
        stocks: stockHistory,
      );

      return BackupImportResult(
        success: true,
        medicationsImported: medications.length,
        doseHistoryImported: doseHistory.length,
        snoozeHistoryImported: snoozeHistory.length,
        stockHistoryImported: stockHistory.length,
        backupDate: DateTime.parse(backupData['timestamp'] as String),
      );
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException('Failed to restore backup: $e');
    }
  }

  Future<String> _pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      dialogTitle: 'Select Backup File',
    );
    if (result == null || result.files.isEmpty) {
      throw BackupException('No file selected');
    }
    final path = result.files.first.path;
    if (path == null) {
      throw BackupException('Invalid file path');
    }
    return path;
  }

  Future<Map<String, dynamic>> _unwrap({
    required Map<String, dynamic> rawJson,
    required String filePath,
    required String? passphrase,
  }) async {
    if (!BackupCrypto.isEncrypted(rawJson)) {
      return rawJson;
    }
    if (passphrase == null || passphrase.isEmpty) {
      throw BackupEncryptedException(filePath);
    }
    try {
      final decrypted = await BackupCrypto.decryptJson(
        wrapper: rawJson,
        passphrase: passphrase,
      );
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } on Object catch (_) {
      throw BackupException('Wrong passphrase or corrupted backup');
    }
  }

  Future<String> _buildBackupJson() async {
    final medications = await _database.getAllMedicationsIncludingInactive();
    final doseHistory = await _database.getAllDoseHistory();
    final snoozeHistory = await _database.getAllSnoozeHistory();
    final stockHistory = await _database.getAllStockHistory();

    final backupData = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'data': {
        'medications':
            medications.map(BackupSerializer.medicationToJson).toList(),
        'doseHistory':
            doseHistory.map(BackupSerializer.doseHistoryToJson).toList(),
        'snoozeHistory':
            snoozeHistory.map(BackupSerializer.snoozeHistoryToJson).toList(),
        'stockHistory':
            stockHistory.map(BackupSerializer.stockHistoryToJson).toList(),
      },
      'statistics': {
        'medicationCount': medications.length,
        'doseHistoryCount': doseHistory.length,
        'snoozeHistoryCount': snoozeHistory.length,
        'stockHistoryCount': stockHistory.length,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  void _validateBackupFormat(Map<String, dynamic> backupData) {
    if (!backupData.containsKey('version')) {
      throw BackupException('Invalid backup format: missing version');
    }
    if (!backupData.containsKey('data')) {
      throw BackupException('Invalid backup format: missing data');
    }
    final data = backupData['data'] as Map<String, dynamic>;
    if (!data.containsKey('medications')) {
      throw BackupException('Invalid backup format: missing medications data');
    }
  }
}
