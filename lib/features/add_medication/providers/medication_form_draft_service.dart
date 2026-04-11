import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:med_assist/core/models/meal_timing.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles saving and loading MedicationFormData drafts to SharedPreferences.
class MedicationFormDraftService {
  const MedicationFormDraftService._();

  static const _draftKey = 'medication_draft';

  static Future<void> saveDraft(MedicationFormData data) async {
    final map = <String, dynamic>{
      'medicineType': data.medicineType?.index,
      'medicineName': data.medicineName,
      'strength': data.strength,
      'unit': data.unit,
      'notes': data.notes,
      'timesPerDay': data.timesPerDay,
      'dosePerTime': data.dosePerTime,
      'doseUnit': data.doseUnit,
      'durationDays': data.durationDays,
      'startDate': data.startDate?.toIso8601String(),
      'reminderTimes': data.reminderTimes
          .map(
            (rt) => {
              'hour': rt.time.hour,
              'minute': rt.time.minute,
              'mealTiming': rt.mealTiming.index,
            },
          )
          .toList(),
      'repetitionPattern': data.repetitionPattern.index,
      'specificDaysOfWeek': data.specificDaysOfWeek,
      'stockQuantity': data.stockQuantity,
      'remindBeforeRunOut': data.remindBeforeRunOut,
      'reminderDaysBeforeRunOut': data.reminderDaysBeforeRunOut,
      'expiryDate': data.expiryDate?.toIso8601String(),
      'reminderDaysBeforeExpiry': data.reminderDaysBeforeExpiry,
      'maxSnoozesPerDay': data.maxSnoozesPerDay,
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode(map));
  }

  static Future<MedicationFormData?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_draftKey);
    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final reminderTimesRaw =
          (map['reminderTimes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final reminderTimes = reminderTimesRaw
          .map(
            (rt) => ReminderTimeData(
              time: TimeOfDay(
                hour: rt['hour'] as int,
                minute: rt['minute'] as int,
              ),
              mealTiming: MealTiming.values[rt['mealTiming'] as int? ?? 0],
            ),
          )
          .toList();

      return MedicationFormData(
        medicineType: map['medicineType'] != null
            ? MedicineType.values[map['medicineType'] as int]
            : null,
        medicineName: map['medicineName'] as String?,
        strength: map['strength'] as String?,
        unit: map['unit'] as String?,
        notes: map['notes'] as String?,
        timesPerDay: map['timesPerDay'] as int? ?? 1,
        dosePerTime: (map['dosePerTime'] as num?)?.toDouble() ?? 1.0,
        doseUnit: map['doseUnit'] as String? ?? 'tablet',
        durationDays: map['durationDays'] as int? ?? 7,
        startDate: map['startDate'] != null
            ? DateTime.parse(map['startDate'] as String)
            : DateTime.now(),
        reminderTimes: reminderTimes,
        repetitionPattern:
            RepetitionPattern.values[map['repetitionPattern'] as int? ?? 0],
        specificDaysOfWeek:
            (map['specificDaysOfWeek'] as List?)?.cast<int>(),
        stockQuantity: map['stockQuantity'] as int? ?? 0,
        remindBeforeRunOut: map['remindBeforeRunOut'] as bool? ?? true,
        reminderDaysBeforeRunOut:
            map['reminderDaysBeforeRunOut'] as int? ?? 3,
        expiryDate: map['expiryDate'] != null
            ? DateTime.parse(map['expiryDate'] as String)
            : null,
        reminderDaysBeforeExpiry: map['reminderDaysBeforeExpiry'] as int?,
        maxSnoozesPerDay: map['maxSnoozesPerDay'] as int? ?? 3,
      );
    } catch (e) {
      debugPrint('Error loading draft: $e');
      return null;
    }
  }

  static Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  static Future<bool> hasDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_draftKey);
  }
}
