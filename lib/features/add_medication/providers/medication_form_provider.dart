import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/models/meal_timing.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_draft_service.dart';

/// Provider for medication form state
final medicationFormProvider =
    NotifierProvider<MedicationFormNotifier, MedicationFormData>(
  MedicationFormNotifier.new,
);

/// Notifier for managing medication form data
class MedicationFormNotifier extends Notifier<MedicationFormData> {
  @override
  MedicationFormData build() {
    return MedicationFormData(
      startDate: DateTime.now(),
      reminderTimes: const [
        ReminderTimeData(time: TimeOfDay(hour: 8, minute: 0)),
      ],
    );
  }

  void reset() {
    state = MedicationFormData(
      startDate: DateTime.now(),
      reminderTimes: const [
        ReminderTimeData(time: TimeOfDay(hour: 8, minute: 0)),
      ],
    );
  }

  Future<void> loadMedication(int medicationId) async {
    try {
      final repository = ref.read(medicationRepositoryProvider);
      final formData = await repository.medicationToFormData(medicationId);
      state = formData.copyWith(id: medicationId);
    } catch (e) {
      debugPrint('Error loading medication: $e');
      rethrow;
    }
  }

  // Step 1 Methods
  void setMedicineType(MedicineType type) =>
      state = state.copyWith(medicineType: type);
  void setMedicineName(String name) =>
      state = state.copyWith(medicineName: name);

  void setMedicinePhoto(String? photoPath) {
    if (photoPath == null) {
      clearMedicinePhoto();
    } else {
      state = state.copyWith(medicinePhotoPath: photoPath);
    }
  }

  void clearMedicinePhoto() {
    final s = state;
    state = MedicationFormData(
      id: s.id,
      medicineType: s.medicineType,
      medicineName: s.medicineName,
      strength: s.strength,
      unit: s.unit,
      notes: s.notes,
      isScanned: s.isScanned,
      timesPerDay: s.timesPerDay,
      dosePerTime: s.dosePerTime,
      doseUnit: s.doseUnit,
      durationDays: s.durationDays,
      startDate: s.startDate,
      reminderTimes: s.reminderTimes,
      repetitionPattern: s.repetitionPattern,
      specificDaysOfWeek: s.specificDaysOfWeek,
      stockQuantity: s.stockQuantity,
      remindBeforeRunOut: s.remindBeforeRunOut,
      reminderDaysBeforeRunOut: s.reminderDaysBeforeRunOut,
      expiryDate: s.expiryDate,
      reminderDaysBeforeExpiry: s.reminderDaysBeforeExpiry,
      customSoundPath: s.customSoundPath,
      maxSnoozesPerDay: s.maxSnoozesPerDay,
      enableRecurringReminders: s.enableRecurringReminders,
      recurringReminderInterval: s.recurringReminderInterval,
    );
  }

  void setStrength(String strength) =>
      state = state.copyWith(strength: strength);
  void setUnit(String unit) => state = state.copyWith(unit: unit);
  void setNotes(String notes) => state = state.copyWith(notes: notes);
  void setIsScanned(bool isScanned) =>
      state = state.copyWith(isScanned: isScanned);

  // Step 2 Methods
  void setTimesPerDay(int times) {
    state = state.copyWith(timesPerDay: times);
    if (state.reminderTimes.length != times) generateDefaultReminderTimes();
  }

  void setDosePerTime(double dose) =>
      state = state.copyWith(dosePerTime: dose);
  void setDoseUnit(String unit) => state = state.copyWith(doseUnit: unit);
  void setDurationDays(int days) => state = state.copyWith(durationDays: days);
  void setStartDate(DateTime date) => state = state.copyWith(startDate: date);
  void setReminderTimes(List<ReminderTimeData> times) =>
      state = state.copyWith(reminderTimes: times);

  void updateReminderTime(int index, TimeOfDay time) {
    final newTimes = List<ReminderTimeData>.from(state.reminderTimes);
    if (index < newTimes.length) {
      newTimes[index] = newTimes[index].copyWith(time: time);
      state = state.copyWith(reminderTimes: newTimes);
    }
  }

  void updateReminderMealTiming(int index, MealTiming mealTiming) {
    final newTimes = List<ReminderTimeData>.from(state.reminderTimes);
    if (index < newTimes.length) {
      newTimes[index] = newTimes[index].copyWith(
        mealTiming: mealTiming,
        mealOffsetMinutes: mealTiming.defaultOffsetMinutes,
      );
      state = state.copyWith(reminderTimes: newTimes);
    }
  }

  void generateDefaultReminderTimes() {
    final times = <ReminderTimeData>[];
    final timesPerDay = state.timesPerDay;

    if (timesPerDay == 1) {
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 8, minute: 0)));
    } else if (timesPerDay == 2) {
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 8, minute: 0)));
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 20, minute: 0)));
    } else if (timesPerDay == 3) {
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 8, minute: 0)));
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 14, minute: 0)));
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 20, minute: 0)));
    } else if (timesPerDay == 4) {
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 8, minute: 0)));
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 12, minute: 0)));
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 16, minute: 0)));
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 20, minute: 0)));
    } else {
      final interval = 24 / timesPerDay;
      for (var i = 0; i < timesPerDay; i++) {
        final hour = (8 + (interval * i)).round() % 24;
        times.add(ReminderTimeData(time: TimeOfDay(hour: hour, minute: 0)));
      }
    }
    state = state.copyWith(reminderTimes: times);
  }

  // Repetition pattern methods
  void setRepetitionPattern(RepetitionPattern pattern) {
    state = state.copyWith(
      repetitionPattern: pattern,
      specificDaysOfWeek: pattern.defaultDays,
    );
  }

  void setSpecificDaysOfWeek(List<int> days) =>
      state = state.copyWith(
        specificDaysOfWeek: days.where((d) => d >= 1 && d <= 7).toList(),
      );

  // Step 3 Methods
  void setStockQuantity(int quantity) =>
      state = state.copyWith(stockQuantity: quantity.clamp(0, 99999));
  void setRemindBeforeRunOut(bool remind) =>
      state = state.copyWith(remindBeforeRunOut: remind);
  void setReminderDaysBeforeRunOut(int days) =>
      state = state.copyWith(reminderDaysBeforeRunOut: days);
  void setExpiryDate(DateTime? date) =>
      state = state.copyWith(expiryDate: date);
  void setReminderDaysBeforeExpiry(int? days) =>
      state = state.copyWith(reminderDaysBeforeExpiry: days);

  // Advanced Reminder Settings
  void setCustomSoundPath(String? soundPath) =>
      state = state.copyWith(customSoundPath: soundPath);
  void setMaxSnoozesPerDay(int maxSnoozes) =>
      state = state.copyWith(maxSnoozesPerDay: maxSnoozes);
  void setEnableRecurringReminders(bool enabled) =>
      state = state.copyWith(enableRecurringReminders: enabled);
  void setRecurringReminderInterval(int minutes) =>
      state = state.copyWith(recurringReminderInterval: minutes);

  // Drug info methods
  void setDrugInfo({
    String? genericName,
    String? activeIngredients,
    String? drugCategory,
    String? purpose,
    String? sideEffects,
    String? drugWarnings,
    String? drugRoute,
  }) {
    state = state.copyWith(
      genericName: genericName,
      activeIngredients: activeIngredients,
      drugCategory: drugCategory,
      purpose: purpose,
      sideEffects: sideEffects,
      drugWarnings: drugWarnings,
      drugRoute: drugRoute,
    );
  }

  // Draft operations (delegated to MedicationFormDraftService)
  Future<void> saveDraft() => MedicationFormDraftService.saveDraft(state);

  Future<bool> loadDraft() async {
    final data = await MedicationFormDraftService.loadDraft();
    if (data != null) state = data;
    return data != null;
  }

  Future<void> clearDraft() => MedicationFormDraftService.clearDraft();

  static Future<bool> hasDraft() => MedicationFormDraftService.hasDraft();

  /// Save medication (insert if new, update if editing)
  Future<bool> saveMedication() async {
    if (!state.isComplete) return false;
    try {
      final repository = ref.read(medicationRepositoryProvider);
      if (state.isEdit) {
        return repository.updateMedication(state.id!, state);
      } else {
        await repository.saveMedication(state);
        return true;
      }
    } catch (e) {
      debugPrint('Error saving medication: $e');
      return false;
    }
  }
}
