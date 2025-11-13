import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/models/meal_timing.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';

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
    );
  }

  /// Reset form
  void reset() {
    state = MedicationFormData(startDate: DateTime.now());
  }

  /// Load medication for editing
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
  void setMedicineType(MedicineType type) {
    state = state.copyWith(medicineType: type);
  }

  void setMedicineName(String name) {
    state = state.copyWith(medicineName: name);
  }

  void setMedicinePhoto(String? photoPath) {
    state = state.copyWith(medicinePhotoPath: photoPath);
  }

  void setStrength(String strength) {
    state = state.copyWith(strength: strength);
  }

  void setUnit(String unit) {
    state = state.copyWith(unit: unit);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void setIsScanned(bool isScanned) {
    state = state.copyWith(isScanned: isScanned);
  }

  // Step 2 Methods
  void setTimesPerDay(int times) {
    state = state.copyWith(timesPerDay: times);
    // Auto-generate reminder times if needed
    if (state.reminderTimes.length != times) {
      generateDefaultReminderTimes();
    }
  }

  void setDosePerTime(double dose) {
    state = state.copyWith(dosePerTime: dose);
  }

  void setDoseUnit(String unit) {
    state = state.copyWith(doseUnit: unit);
  }

  void setDurationDays(int days) {
    state = state.copyWith(durationDays: days);
  }

  void setStartDate(DateTime date) {
    state = state.copyWith(startDate: date);
  }

  void setReminderTimes(List<ReminderTimeData> times) {
    state = state.copyWith(reminderTimes: times);
  }

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

  /// Generate default reminder times based on times per day
  void generateDefaultReminderTimes() {
    final times = <ReminderTimeData>[];
    final timesPerDay = state.timesPerDay;

    if (timesPerDay == 1) {
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 8, minute: 0))); // 8 AM
    } else if (timesPerDay == 2) {
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 8, minute: 0))); // 8 AM
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 20, minute: 0))); // 8 PM
    } else if (timesPerDay == 3) {
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 8, minute: 0))); // 8 AM
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 14, minute: 0))); // 2 PM
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 20, minute: 0))); // 8 PM
    } else if (timesPerDay == 4) {
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 8, minute: 0))); // 8 AM
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 12, minute: 0))); // 12 PM
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 16, minute: 0))); // 4 PM
      times.add(const ReminderTimeData(time: TimeOfDay(hour: 20, minute: 0))); // 8 PM
    } else {
      // Evenly distribute throughout the day
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

  void setSpecificDaysOfWeek(List<int> days) {
    state = state.copyWith(specificDaysOfWeek: days);
  }

  // Step 3 Methods
  void setStockQuantity(int quantity) {
    state = state.copyWith(stockQuantity: quantity);
  }

  void setRemindBeforeRunOut(bool remind) {
    state = state.copyWith(remindBeforeRunOut: remind);
  }

  void setReminderDaysBeforeRunOut(int days) {
    state = state.copyWith(reminderDaysBeforeRunOut: days);
  }

  void setExpiryDate(DateTime? date) {
    state = state.copyWith(expiryDate: date);
  }

  void setReminderDaysBeforeExpiry(int? days) {
    state = state.copyWith(reminderDaysBeforeExpiry: days);
  }

  // Advanced Reminder Settings
  void setCustomSoundPath(String? soundPath) {
    state = state.copyWith(customSoundPath: soundPath);
  }

  void setMaxSnoozesPerDay(int maxSnoozes) {
    state = state.copyWith(maxSnoozesPerDay: maxSnoozes);
  }

  void setEnableRecurringReminders(bool enabled) {
    state = state.copyWith(enableRecurringReminders: enabled);
  }

  void setRecurringReminderInterval(int minutes) {
    state = state.copyWith(recurringReminderInterval: minutes);
  }

  /// Save medication (insert if new, update if editing)
  Future<bool> saveMedication() async {
    if (!state.isComplete) return false;

    try {
      final repository = ref.read(medicationRepositoryProvider);

      if (state.isEdit) {
        // Update existing medication
        final success = await repository.updateMedication(state.id!, state);
        return success;
      } else {
        // Insert new medication
        await repository.saveMedication(state);
        return true;
      }
    } catch (e) {
      // Log error
      debugPrint('Error saving medication: $e');
      return false;
    }
  }
}

/// Provider for current step
final currentStepProvider = NotifierProvider<CurrentStepNotifier, int>(
  CurrentStepNotifier.new,
);

/// Notifier for managing current step
class CurrentStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setStep(int step) {
    state = step;
  }

  void nextStep() {
    if (state < 2) {
      state = state + 1;
    }
  }

  void previousStep() {
    if (state > 0) {
      state = state - 1;
    }
  }

  void reset() {
    state = 0;
  }
}
