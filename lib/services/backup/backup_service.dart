import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for backing up and restoring app data
class BackupService {

  BackupService(this._database);
  final AppDatabase _database;

  /// Export all data to JSON file
  /// Returns the file path of the backup
  Future<String> createBackup() async {
    try {
      // Fetch all data
      final medications = await _database.getAllMedicationsIncludingInactive();
      final doseHistory = await _database.getAllDoseHistory();
      final snoozeHistory = await _database.getAllSnoozeHistory();
      final stockHistory = await _database.getAllStockHistory();

      // Create backup data structure
      final backupData = {
        'version': 1, // Backup format version
        'timestamp': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'data': {
          'medications': medications
              .map(_medicationToJson)
              .toList(),
          'doseHistory': doseHistory
              .map(_doseHistoryToJson)
              .toList(),
          'snoozeHistory': snoozeHistory
              .map(_snoozeHistoryToJson)
              .toList(),
          'stockHistory': stockHistory
              .map(_stockHistoryToJson)
              .toList(),
        },
        'statistics': {
          'medicationCount': medications.length,
          'doseHistoryCount': doseHistory.length,
          'snoozeHistoryCount': snoozeHistory.length,
          'stockHistoryCount': stockHistory.length,
        },
      };

      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final fileName = 'medassist_backup_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(jsonString);

      return filePath;
    } catch (e) {
      throw BackupException('Failed to create backup: $e');
    }
  }

  /// Share backup file
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

  /// Import data from backup file
  Future<BackupImportResult> restoreBackup({String? filePath}) async {
    try {
      // If no file path provided, let user pick a file
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

      // Read file
      final file = File(backupFilePath);
      if (!await file.exists()) {
        throw BackupException('Backup file not found');
      }

      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup format
      _validateBackupFormat(backupData);

      // Extract data
      final data = backupData['data'] as Map<String, dynamic>;
      final medications = (data['medications'] as List<dynamic>)
          .map((json) => _medicationFromJson(json as Map<String, dynamic>))
          .toList();
      final doseHistory = (data['doseHistory'] as List<dynamic>)
          .map((json) => _doseHistoryFromJson(json as Map<String, dynamic>))
          .toList();
      final snoozeHistory = (data['snoozeHistory'] as List<dynamic>)
          .map((json) => _snoozeHistoryFromJson(json as Map<String, dynamic>))
          .toList();
      final stockHistory = (data['stockHistory'] as List<dynamic>)
          .map((json) => _stockHistoryFromJson(json as Map<String, dynamic>))
          .toList();

      // Clear existing data
      await _database.clearAllData();

      // Import data
      var medicationsImported = 0;
      var doseHistoryImported = 0;
      var snoozeHistoryImported = 0;
      var stockHistoryImported = 0;

      // Import medications
      for (final medication in medications) {
        await _database.insertMedication(medication);
        medicationsImported++;
      }

      // Import dose history
      for (final dose in doseHistory) {
        await _database.insertDoseHistory(dose);
        doseHistoryImported++;
      }

      // Import snooze history
      for (final snooze in snoozeHistory) {
        await _database.insertSnoozeHistory(snooze);
        snoozeHistoryImported++;
      }

      // Import stock history
      for (final stock in stockHistory) {
        await _database.insertStockHistory(stock);
        stockHistoryImported++;
      }

      return BackupImportResult(
        success: true,
        medicationsImported: medicationsImported,
        doseHistoryImported: doseHistoryImported,
        snoozeHistoryImported: snoozeHistoryImported,
        stockHistoryImported: stockHistoryImported,
        backupDate: DateTime.parse(backupData['timestamp'] as String),
      );
    } catch (e) {
      throw BackupException('Failed to restore backup: $e');
    }
  }

  /// Validate backup format
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

  // JSON conversion methods for Medication
  Map<String, dynamic> _medicationToJson(Medication m) {
    return {
      'id': m.id,
      'medicineName': m.medicineName,
      'medicineType': m.medicineType,
      'medicinePhotoPath': m.medicinePhotoPath,
      'strength': m.strength,
      'unit': m.unit,
      'notes': m.notes,
      'isScanned': m.isScanned,
      'timesPerDay': m.timesPerDay,
      'dosePerTime': m.dosePerTime,
      'doseUnit': m.doseUnit,
      'durationDays': m.durationDays,
      'startDate': m.startDate.toIso8601String(),
      'repetitionPattern': m.repetitionPattern,
      'specificDaysOfWeek': m.specificDaysOfWeek,
      'stockQuantity': m.stockQuantity,
      'remindBeforeRunOut': m.remindBeforeRunOut,
      'reminderDaysBeforeRunOut': m.reminderDaysBeforeRunOut,
      'expiryDate': m.expiryDate?.toIso8601String(),
      'reminderDaysBeforeExpiry': m.reminderDaysBeforeExpiry,
      'customSoundPath': m.customSoundPath,
      'maxSnoozesPerDay': m.maxSnoozesPerDay,
      'enableRecurringReminders': m.enableRecurringReminders,
      'recurringReminderInterval': m.recurringReminderInterval,
      'createdAt': m.createdAt.toIso8601String(),
      'updatedAt': m.updatedAt.toIso8601String(),
      'isActive': m.isActive,
    };
  }

  MedicationsCompanion _medicationFromJson(Map<String, dynamic> json) {
    return MedicationsCompanion.insert(
      id: drift.Value(json['id'] as int),
      medicineName: json['medicineName'] as String,
      medicineType: json['medicineType'] as String,
      medicinePhotoPath: drift.Value(json['medicinePhotoPath'] as String?),
      strength: drift.Value(json['strength'] as String?),
      unit: drift.Value(json['unit'] as String?),
      notes: drift.Value(json['notes'] as String?),
      isScanned: drift.Value(json['isScanned'] as bool? ?? false),
      timesPerDay: drift.Value(json['timesPerDay'] as int? ?? 1),
      dosePerTime: drift.Value((json['dosePerTime'] as num?)?.toDouble() ?? 1.0),
      doseUnit: drift.Value(json['doseUnit'] as String? ?? 'tablet'),
      durationDays: drift.Value(json['durationDays'] as int? ?? 7),
      startDate: DateTime.parse(json['startDate'] as String),
      repetitionPattern: drift.Value(json['repetitionPattern'] as String? ?? 'daily'),
      specificDaysOfWeek: drift.Value(json['specificDaysOfWeek'] as String? ?? '1,2,3,4,5,6,7'),
      stockQuantity: drift.Value(json['stockQuantity'] as int? ?? 0),
      remindBeforeRunOut: drift.Value(json['remindBeforeRunOut'] as bool? ?? true),
      reminderDaysBeforeRunOut: drift.Value(json['reminderDaysBeforeRunOut'] as int? ?? 3),
      expiryDate: drift.Value(json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null),
      reminderDaysBeforeExpiry: drift.Value(json['reminderDaysBeforeExpiry'] as int? ?? 30),
      customSoundPath: drift.Value(json['customSoundPath'] as String?),
      maxSnoozesPerDay: drift.Value(json['maxSnoozesPerDay'] as int? ?? 3),
      enableRecurringReminders: drift.Value(json['enableRecurringReminders'] as bool? ?? false),
      recurringReminderInterval: drift.Value(json['recurringReminderInterval'] as int? ?? 30),
      createdAt: drift.Value(DateTime.parse(json['createdAt'] as String)),
      updatedAt: drift.Value(DateTime.parse(json['updatedAt'] as String)),
      isActive: drift.Value(json['isActive'] as bool? ?? true),
    );
  }

  // JSON conversion methods for DoseHistory
  Map<String, dynamic> _doseHistoryToJson(DoseHistoryData d) {
    return {
      'id': d.id,
      'medicationId': d.medicationId,
      'scheduledDate': d.scheduledDate.toIso8601String(),
      'scheduledHour': d.scheduledHour,
      'scheduledMinute': d.scheduledMinute,
      'status': d.status,
      'actualTime': d.actualTime?.toIso8601String(),
      'notes': d.notes,
      'createdAt': d.createdAt.toIso8601String(),
    };
  }

  DoseHistoryCompanion _doseHistoryFromJson(Map<String, dynamic> json) {
    return DoseHistoryCompanion.insert(
      id: drift.Value(json['id'] as int),
      medicationId: json['medicationId'] as int,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      scheduledHour: json['scheduledHour'] as int,
      scheduledMinute: json['scheduledMinute'] as int,
      status: json['status'] as String,
      actualTime: drift.Value(json['actualTime'] != null
          ? DateTime.parse(json['actualTime'] as String)
          : null),
      notes: drift.Value(json['notes'] as String?),
      createdAt: drift.Value(DateTime.parse(json['createdAt'] as String)),
    );
  }

  // JSON conversion methods for SnoozeHistory
  Map<String, dynamic> _snoozeHistoryToJson(SnoozeHistoryData s) {
    return {
      'id': s.id,
      'medicationId': s.medicationId,
      'snoozeDate': s.snoozeDate.toIso8601String(),
      'snoozeCount': s.snoozeCount,
      'lastSnoozeTime': s.lastSnoozeTime.toIso8601String(),
      'suggestedMinutes': s.suggestedMinutes,
    };
  }

  SnoozeHistoryTableCompanion _snoozeHistoryFromJson(Map<String, dynamic> json) {
    return SnoozeHistoryTableCompanion.insert(
      id: drift.Value(json['id'] as int),
      medicationId: json['medicationId'] as int,
      snoozeDate: DateTime.parse(json['snoozeDate'] as String),
      snoozeCount: drift.Value(json['snoozeCount'] as int? ?? 0),
      lastSnoozeTime: DateTime.parse(json['lastSnoozeTime'] as String),
      suggestedMinutes: drift.Value(json['suggestedMinutes'] as int? ?? 15),
    );
  }

  // JSON conversion methods for StockHistory
  Map<String, dynamic> _stockHistoryToJson(StockHistoryData s) {
    return {
      'id': s.id,
      'medicationId': s.medicationId,
      'previousStock': s.previousStock,
      'newStock': s.newStock,
      'changeAmount': s.changeAmount,
      'changeType': s.changeType,
      'notes': s.notes,
      'changeDate': s.changeDate.toIso8601String(),
    };
  }

  StockHistoryCompanion _stockHistoryFromJson(Map<String, dynamic> json) {
    return StockHistoryCompanion.insert(
      id: drift.Value(json['id'] as int),
      medicationId: json['medicationId'] as int,
      previousStock: json['previousStock'] as int,
      newStock: json['newStock'] as int,
      changeAmount: json['changeAmount'] as int,
      changeType: json['changeType'] as String,
      notes: drift.Value(json['notes'] as String?),
      changeDate: drift.Value(DateTime.parse(json['changeDate'] as String)),
    );
  }
}

/// Result of a backup import operation
class BackupImportResult {

  BackupImportResult({
    required this.success,
    required this.medicationsImported,
    required this.doseHistoryImported,
    required this.snoozeHistoryImported,
    required this.stockHistoryImported,
    required this.backupDate,
  });
  final bool success;
  final int medicationsImported;
  final int doseHistoryImported;
  final int snoozeHistoryImported;
  final int stockHistoryImported;
  final DateTime backupDate;

  int get totalImported =>
      medicationsImported +
      doseHistoryImported +
      snoozeHistoryImported +
      stockHistoryImported;
}

/// Exception thrown when backup/restore operations fail
class BackupException implements Exception {

  BackupException(this.message);
  final String message;

  @override
  String toString() => 'BackupException: $message';
}
