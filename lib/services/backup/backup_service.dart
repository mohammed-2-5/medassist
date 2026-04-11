import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/services/backup/backup_exception.dart';
import 'package:med_assist/services/backup/backup_import_result.dart';
import 'package:med_assist/services/backup/backup_serializer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for backing up and restoring app data
class BackupService {
  BackupService(this._database);

  final AppDatabase _database;

  /// Export all data to JSON file. Returns the file path of the backup.
  Future<String> createBackup() async {
    try {
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

      final jsonString =
          const JsonEncoder.withIndent('  ').convert(backupData);
      final directory = await getApplicationDocumentsDirectory();
      final timestamp =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filePath =
          '${directory.path}/medassist_backup_$timestamp.json';

      await File(filePath).writeAsString(jsonString);
      return filePath;
    } catch (e) {
      throw BackupException('Failed to create backup: $e');
    }
  }

  /// Share backup file via share sheet
  Future<void> shareBackup() async {
    try {
      final filePath = await createBackup();
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'MedAssist Backup',
        text: 'MedAssist medication data backup',
      );
    } catch (e) {
      throw BackupException('Failed to share backup: $e');
    }
  }

  /// Import data from a backup JSON file
  Future<BackupImportResult> restoreBackup({String? filePath}) async {
    try {
      var backupFilePath = filePath;

      if (backupFilePath == null) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
          dialogTitle: 'Select Backup File',
        );
        if (result == null || result.files.isEmpty) {
          throw BackupException('No file selected');
        }
        backupFilePath = result.files.first.path;
        if (backupFilePath == null) {
          throw BackupException('Invalid file path');
        }
      }

      final file = File(backupFilePath);
      if (!await file.exists()) {
        throw BackupException('Backup file not found');
      }

      final backupData =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _validateBackupFormat(backupData);

      final data = backupData['data'] as Map<String, dynamic>;
      final medications = (data['medications'] as List<dynamic>)
          .map((j) => BackupSerializer.medicationFromJson(j as Map<String, dynamic>))
          .toList();
      final doseHistory = (data['doseHistory'] as List<dynamic>)
          .map((j) => BackupSerializer.doseHistoryFromJson(j as Map<String, dynamic>))
          .toList();
      final snoozeHistory = (data['snoozeHistory'] as List<dynamic>)
          .map((j) => BackupSerializer.snoozeHistoryFromJson(j as Map<String, dynamic>))
          .toList();
      final stockHistory = (data['stockHistory'] as List<dynamic>)
          .map((j) => BackupSerializer.stockHistoryFromJson(j as Map<String, dynamic>))
          .toList();

      // Atomic restore: clear + insert in a single transaction.
      // If any insert fails, the entire operation is rolled back.
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
      throw BackupException('Failed to restore backup: $e');
    }
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
