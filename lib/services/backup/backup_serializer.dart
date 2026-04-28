import 'package:drift/drift.dart' as drift;
import 'package:med_assist/core/database/app_database.dart';

/// Static JSON serialization helpers used by BackupService.
class BackupSerializer {
  const BackupSerializer._();

  static Map<String, dynamic> medicationToJson(Medication m) => {
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

  static MedicationsCompanion medicationFromJson(Map<String, dynamic> json) =>
      MedicationsCompanion.insert(
        id: drift.Value(json['id'] as int),
        medicineName: json['medicineName'] as String,
        medicineType: json['medicineType'] as String,
        medicinePhotoPath: drift.Value(json['medicinePhotoPath'] as String?),
        strength: drift.Value(json['strength'] as String?),
        unit: drift.Value(json['unit'] as String?),
        notes: drift.Value(json['notes'] as String?),
        isScanned: drift.Value(json['isScanned'] as bool? ?? false),
        timesPerDay: drift.Value(json['timesPerDay'] as int? ?? 1),
        dosePerTime: drift.Value(
          (json['dosePerTime'] as num?)?.toDouble() ?? 1.0,
        ),
        doseUnit: drift.Value(json['doseUnit'] as String? ?? 'tablet'),
        durationDays: drift.Value(json['durationDays'] as int? ?? 7),
        startDate: DateTime.parse(json['startDate'] as String),
        repetitionPattern: drift.Value(
          json['repetitionPattern'] as String? ?? 'daily',
        ),
        specificDaysOfWeek: drift.Value(
          json['specificDaysOfWeek'] as String? ?? '1,2,3,4,5,6,7',
        ),
        stockQuantity: drift.Value(json['stockQuantity'] as int? ?? 0),
        remindBeforeRunOut: drift.Value(
          json['remindBeforeRunOut'] as bool? ?? true,
        ),
        reminderDaysBeforeRunOut: drift.Value(
          json['reminderDaysBeforeRunOut'] as int? ?? 3,
        ),
        expiryDate: drift.Value(
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'] as String)
              : null,
        ),
        reminderDaysBeforeExpiry: drift.Value(
          json['reminderDaysBeforeExpiry'] as int? ?? 30,
        ),
        customSoundPath: drift.Value(json['customSoundPath'] as String?),
        maxSnoozesPerDay: drift.Value(json['maxSnoozesPerDay'] as int? ?? 3),
        enableRecurringReminders: drift.Value(
          json['enableRecurringReminders'] as bool? ?? false,
        ),
        recurringReminderInterval: drift.Value(
          json['recurringReminderInterval'] as int? ?? 30,
        ),
        createdAt: drift.Value(DateTime.parse(json['createdAt'] as String)),
        updatedAt: drift.Value(DateTime.parse(json['updatedAt'] as String)),
        isActive: drift.Value(json['isActive'] as bool? ?? true),
      );

  static Map<String, dynamic> doseHistoryToJson(DoseHistoryData d) => {
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

  static DoseHistoryCompanion doseHistoryFromJson(
    Map<String, dynamic> json,
  ) => DoseHistoryCompanion.insert(
    id: drift.Value(json['id'] as int),
    medicationId: json['medicationId'] as int,
    scheduledDate: DateTime.parse(json['scheduledDate'] as String),
    scheduledHour: json['scheduledHour'] as int,
    scheduledMinute: json['scheduledMinute'] as int,
    status: json['status'] as String,
    actualTime: drift.Value(
      json['actualTime'] != null
          ? DateTime.parse(json['actualTime'] as String)
          : null,
    ),
    notes: drift.Value(json['notes'] as String?),
    createdAt: drift.Value(DateTime.parse(json['createdAt'] as String)),
  );

  static Map<String, dynamic> snoozeHistoryToJson(SnoozeHistoryData s) => {
    'id': s.id,
    'medicationId': s.medicationId,
    'snoozeDate': s.snoozeDate.toIso8601String(),
    'snoozeCount': s.snoozeCount,
    'lastSnoozeTime': s.lastSnoozeTime.toIso8601String(),
    'suggestedMinutes': s.suggestedMinutes,
  };

  static SnoozeHistoryTableCompanion snoozeHistoryFromJson(
    Map<String, dynamic> json,
  ) => SnoozeHistoryTableCompanion.insert(
    id: drift.Value(json['id'] as int),
    medicationId: json['medicationId'] as int,
    snoozeDate: DateTime.parse(json['snoozeDate'] as String),
    snoozeCount: drift.Value(json['snoozeCount'] as int? ?? 0),
    lastSnoozeTime: DateTime.parse(json['lastSnoozeTime'] as String),
    suggestedMinutes: drift.Value(json['suggestedMinutes'] as int? ?? 15),
  );

  static Map<String, dynamic> stockHistoryToJson(StockHistoryData s) => {
    'id': s.id,
    'medicationId': s.medicationId,
    'previousStock': s.previousStock,
    'newStock': s.newStock,
    'changeAmount': s.changeAmount,
    'changeType': s.changeType,
    'notes': s.notes,
    'changeDate': s.changeDate.toIso8601String(),
  };

  static StockHistoryCompanion stockHistoryFromJson(
    Map<String, dynamic> json,
  ) => StockHistoryCompanion.insert(
    id: drift.Value(json['id'] as int),
    medicationId: json['medicationId'] as int,
    previousStock: json['previousStock'] as int,
    newStock: json['newStock'] as int,
    changeAmount: json['changeAmount'] as int,
    changeType: json['changeType'] as String,
    notes: drift.Value(json['notes'] as String?),
    changeDate: drift.Value(
      DateTime.parse(json['changeDate'] as String),
    ),
  );
}
