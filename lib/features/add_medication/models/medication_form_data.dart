import 'package:flutter/material.dart';
import 'package:med_assist/core/models/meal_timing.dart';
import 'package:med_assist/core/utils/repetition_pattern_utils.dart';

/// Medication Form Data Model for Add Medicine Wizard

/// Reminder time data with meal timing
class ReminderTimeData {
  const ReminderTimeData({
    required this.time,
    this.mealTiming = MealTiming.anytime,
    int? mealOffsetMinutes,
  }) : mealOffsetMinutes = mealOffsetMinutes ?? 0;
  final TimeOfDay time;
  final MealTiming mealTiming;
  final int mealOffsetMinutes;

  ReminderTimeData copyWith({
    TimeOfDay? time,
    MealTiming? mealTiming,
    int? mealOffsetMinutes,
  }) {
    return ReminderTimeData(
      time: time ?? this.time,
      mealTiming: mealTiming ?? this.mealTiming,
      mealOffsetMinutes: mealOffsetMinutes ?? this.mealOffsetMinutes,
    );
  }
}

/// Medicine type enum
enum MedicineType {
  pill('💊 Pill', 'Tablet or capsule'),
  injection('💉 Injection', 'Injectable medicine'),
  suppository('🌡️ Suppository', 'Rectal or vaginal'),
  ivSolution('💧 IV Solution', 'Intravenous drip'),
  syrup('🥄 Syrup', 'Liquid medicine'),
  drops('💧 Drops', 'Eye or ear drops');

  const MedicineType(this.label, this.description);
  final String label;
  final String description;
}

/// Medication repetition pattern enum
enum RepetitionPattern {
  daily('📅 Every Day', 'Take medication daily', [1, 2, 3, 4, 5, 6, 7]),
  everyOtherDay('📅 Every Other Day', 'Take medication every 2 days', [
    1,
    3,
    5,
    7,
  ]),
  twiceAWeek('📅 Twice a Week', 'Take medication 2 days per week', [1, 4]),
  thriceAWeek('📅 Thrice a Week', 'Take medication 3 days per week', [1, 3, 5]),
  weekdays('📅 Weekdays Only', 'Monday to Friday', [1, 2, 3, 4, 5]),
  weekends('📅 Weekends Only', 'Saturday and Sunday', [6, 7]),
  specificDays('📅 Specific Days', 'Choose which days', []),
  asNeeded('📅 As Needed', 'Take only when needed', []),
  everyNDays('📅 Every N Days', 'Repeat every N days', []),
  weekly('📅 Weekly', 'Repeat on selected weekdays', []),
  monthly('📅 Monthly', 'Repeat on a day of the month', []);

  const RepetitionPattern(this.label, this.description, this.defaultDays);
  final String label;
  final String description;
  final List<int> defaultDays; // 1=Monday, 7=Sunday

  /// Get weekday name
  static String getWeekdayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(day - 1).clamp(0, 6)];
  }
}

/// Medication form data holder for all 3 steps
class MedicationFormData {
  MedicationFormData({
    this.id,
    this.medicineType,
    this.medicineName,
    this.medicinePhotoPath,
    this.strength,
    this.unit,
    this.notes,
    this.isScanned = false,
    this.timesPerDay = 1,
    this.dosePerTime = 1.0,
    this.doseUnit = 'tablet',
    this.durationDays = 7,
    this.startDate,
    List<ReminderTimeData>? reminderTimes,
    this.repetitionPattern = RepetitionPattern.daily,
    List<int>? specificDaysOfWeek,
    this.intervalDays,
    this.intervalWeeks,
    this.intervalMonths,
    this.dayOfMonth,
    this.stockQuantity = 0,
    this.remindBeforeRunOut = true,
    this.reminderDaysBeforeRunOut = 3,
    this.expiryDate,
    this.reminderDaysBeforeExpiry,
    this.customSoundPath,
    this.maxSnoozesPerDay = 3,
    this.enableRecurringReminders,
    this.recurringReminderInterval,
    this.genericName,
    this.activeIngredients,
    this.drugCategory,
    this.purpose,
    this.sideEffects,
    this.drugWarnings,
    this.drugRoute,
  }) : reminderTimes = reminderTimes ?? [],
       specificDaysOfWeek = specificDaysOfWeek ?? repetitionPattern.defaultDays;
  // ID (null for new, set for edit)
  int? id;

  // Step 1: Type & Info
  MedicineType? medicineType;
  String? medicineName;
  String? medicinePhotoPath;
  String? strength;
  String? unit;
  String? notes;
  bool isScanned;

  // Step 2: Schedule & Duration
  int timesPerDay;
  double dosePerTime;
  String doseUnit;
  int durationDays;
  DateTime? startDate;
  List<ReminderTimeData> reminderTimes;

  // Repetition pattern
  RepetitionPattern repetitionPattern;
  List<int> specificDaysOfWeek; // For specificDays pattern (1=Mon, 7=Sun)

  // Smart schedule intervals (Issue 3)
  int? intervalDays; // everyNDays
  int? intervalWeeks; // weekly every-N-weeks
  int? intervalMonths; // monthly every-N-months
  int? dayOfMonth; // monthly 1-31

  // Step 3: Stock & Reminder
  int stockQuantity;
  bool remindBeforeRunOut;
  int reminderDaysBeforeRunOut;
  DateTime? expiryDate;
  int? reminderDaysBeforeExpiry;

  // Advanced Reminder Settings
  String? customSoundPath;
  int maxSnoozesPerDay;
  bool? enableRecurringReminders;
  int? recurringReminderInterval;

  // AI-enriched drug info
  String? genericName;
  String? activeIngredients;
  String? drugCategory;
  String? purpose;
  String? sideEffects;
  String? drugWarnings;
  String? drugRoute;

  /// Check if this is an edit (has ID) or new medication
  bool get isEdit => id != null;

  MedicationFormData copyWith({
    int? id,
    MedicineType? medicineType,
    String? medicineName,
    String? medicinePhotoPath,
    String? strength,
    String? unit,
    String? notes,
    bool? isScanned,
    int? timesPerDay,
    double? dosePerTime,
    String? doseUnit,
    int? durationDays,
    DateTime? startDate,
    List<ReminderTimeData>? reminderTimes,
    RepetitionPattern? repetitionPattern,
    List<int>? specificDaysOfWeek,
    int? intervalDays,
    int? intervalWeeks,
    int? intervalMonths,
    int? dayOfMonth,
    int? stockQuantity,
    bool? remindBeforeRunOut,
    int? reminderDaysBeforeRunOut,
    DateTime? expiryDate,
    int? reminderDaysBeforeExpiry,
    String? customSoundPath,
    int? maxSnoozesPerDay,
    bool? enableRecurringReminders,
    int? recurringReminderInterval,
    String? genericName,
    String? activeIngredients,
    String? drugCategory,
    String? purpose,
    String? sideEffects,
    String? drugWarnings,
    String? drugRoute,
  }) {
    return MedicationFormData(
      id: id ?? this.id,
      medicineType: medicineType ?? this.medicineType,
      medicineName: medicineName ?? this.medicineName,
      medicinePhotoPath: medicinePhotoPath ?? this.medicinePhotoPath,
      strength: strength ?? this.strength,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      isScanned: isScanned ?? this.isScanned,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      dosePerTime: dosePerTime ?? this.dosePerTime,
      doseUnit: doseUnit ?? this.doseUnit,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      repetitionPattern: repetitionPattern ?? this.repetitionPattern,
      specificDaysOfWeek: specificDaysOfWeek ?? this.specificDaysOfWeek,
      intervalDays: intervalDays ?? this.intervalDays,
      intervalWeeks: intervalWeeks ?? this.intervalWeeks,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      remindBeforeRunOut: remindBeforeRunOut ?? this.remindBeforeRunOut,
      reminderDaysBeforeRunOut:
          reminderDaysBeforeRunOut ?? this.reminderDaysBeforeRunOut,
      expiryDate: expiryDate ?? this.expiryDate,
      reminderDaysBeforeExpiry:
          reminderDaysBeforeExpiry ?? this.reminderDaysBeforeExpiry,
      customSoundPath: customSoundPath ?? this.customSoundPath,
      maxSnoozesPerDay: maxSnoozesPerDay ?? this.maxSnoozesPerDay,
      enableRecurringReminders:
          enableRecurringReminders ?? this.enableRecurringReminders,
      recurringReminderInterval:
          recurringReminderInterval ?? this.recurringReminderInterval,
      genericName: genericName ?? this.genericName,
      activeIngredients: activeIngredients ?? this.activeIngredients,
      drugCategory: drugCategory ?? this.drugCategory,
      purpose: purpose ?? this.purpose,
      sideEffects: sideEffects ?? this.sideEffects,
      drugWarnings: drugWarnings ?? this.drugWarnings,
      drugRoute: drugRoute ?? this.drugRoute,
    );
  }

  /// Calculate when stock will run out, accounting for repetition pattern.
  DateTime? get stockRunOutDate {
    if (stockQuantity <= 0 || timesPerDay <= 0) return null;

    final doseDays = RepetitionPatternUtils.doseDaysPerWeek(
      pattern: repetitionPattern.name,
      specificDaysOfWeek: specificDaysOfWeek.join(','),
      intervalDays: intervalDays,
      intervalWeeks: intervalWeeks,
      intervalMonths: intervalMonths,
    );
    if (doseDays <= 0) return null;

    final perDoseUsage = dosePerTime * timesPerDay;
    final avgDailyUsage = perDoseUsage * doseDays / 7;
    if (avgDailyUsage <= 0) return null;

    final daysRemaining = (stockQuantity / avgDailyUsage).floor();
    return DateTime.now().add(Duration(days: daysRemaining));
  }

  /// Calculate reminder date for low stock
  DateTime? get lowStockReminderDate {
    final runOutDate = stockRunOutDate;
    if (runOutDate == null) return null;

    return runOutDate.subtract(Duration(days: reminderDaysBeforeRunOut));
  }

  /// Validate Step 1
  bool get isStep1Valid {
    return medicineType != null &&
        medicineName != null &&
        medicineName!.trim().isNotEmpty;
  }

  /// Validate Step 2
  bool get isStep2Valid {
    return timesPerDay > 0 &&
        dosePerTime > 0 &&
        durationDays > 0 &&
        startDate != null &&
        reminderTimes.length == timesPerDay;
  }

  /// Validate Step 3
  bool get isStep3Valid {
    return stockQuantity >= 0;
  }

  /// Check if all steps are valid
  bool get isComplete {
    return isStep1Valid && isStep2Valid && isStep3Valid;
  }
}
