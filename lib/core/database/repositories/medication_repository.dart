import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/models/meal_timing.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// Repository for medication data operations
class MedicationRepository {

  MedicationRepository(this._database);
  final AppDatabase _database;
  final NotificationService _notificationService = NotificationService();

  /// Get all active medications
  Future<List<Medication>> getAllMedications() {
    return _database.getAllMedications();
  }

  /// Get a single medication by ID
  Future<Medication?> getMedicationById(int id) {
    return _database.getMedicationById(id);
  }

  /// Get medications for today
  Future<List<Medication>> getTodaysMedications() {
    return _database.getTodaysMedications();
  }

  /// Get medications with their reminder times
  Future<List<MedicationWithReminders>> getMedicationsWithReminders() {
    return _database.getMedicationsWithReminders();
  }

  /// Search medications by name
  Future<List<Medication>> searchMedications(String query) {
    return _database.searchMedications(query);
  }

  /// Get medications that are running low on stock
  Future<List<Medication>> getLowStockMedications() {
    return _database.getLowStockMedications();
  }

  /// Save a new medication from form data
  Future<int> saveMedication(MedicationFormData formData) async {
    // Convert form data to database companion
    final companion = MedicationsCompanion.insert(
      medicineType: formData.medicineType!.name,
      medicineName: formData.medicineName!,
      medicinePhotoPath: drift.Value(formData.medicinePhotoPath),
      strength: drift.Value(formData.strength),
      unit: drift.Value(formData.unit),
      notes: drift.Value(formData.notes),
      isScanned: drift.Value(formData.isScanned),
      timesPerDay: drift.Value(formData.timesPerDay),
      dosePerTime: drift.Value(formData.dosePerTime),
      doseUnit: drift.Value(formData.doseUnit),
      durationDays: drift.Value(formData.durationDays),
      startDate: formData.startDate ?? DateTime.now(),
      stockQuantity: drift.Value(formData.stockQuantity),
      remindBeforeRunOut: drift.Value(formData.remindBeforeRunOut),
      reminderDaysBeforeRunOut: drift.Value(formData.reminderDaysBeforeRunOut),
      customSoundPath: drift.Value(formData.customSoundPath),
      maxSnoozesPerDay: drift.Value(formData.maxSnoozesPerDay),
    );

    // Insert medication
    final medicationId = await _database.insertMedication(companion);

    // Insert reminder times
    if (formData.reminderTimes.isNotEmpty) {
      final times = formData.reminderTimes
          .map((reminderData) => (
                hour: reminderData.time.hour,
                minute: reminderData.time.minute,
                mealTiming: reminderData.mealTiming.value,
                mealOffsetMinutes: reminderData.mealOffsetMinutes,
              ))
          .toList();
      await _database.insertReminderTimes(medicationId, times);
    }

    // Schedule notifications for the new medication
    try {
      final medication = await _database.getMedicationById(medicationId);
      if (medication != null) {
        final reminderTimes = await _database.getReminderTimes(medicationId);
        await _notificationService.scheduleRemindersForMedication(
          medication,
          reminderTimes,
        );
        debugPrint('Scheduled notifications for medication $medicationId');
      }
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
      // Don't fail the save if notification scheduling fails
    }

    return medicationId;
  }

  /// Update an existing medication
  Future<bool> updateMedication(
    int medicationId,
    MedicationFormData formData,
  ) async {
    // Get existing medication
    final existing = await _database.getMedicationById(medicationId);
    if (existing == null) return false;

    // Create updated medication
    final updated = existing.copyWith(
      medicineType: formData.medicineType!.name,
      medicineName: formData.medicineName,
      medicinePhotoPath:
          drift.Value(formData.medicinePhotoPath),
      strength: drift.Value(formData.strength),
      unit: drift.Value(formData.unit),
      notes: drift.Value(formData.notes),
      isScanned: formData.isScanned,
      timesPerDay: formData.timesPerDay,
      dosePerTime: formData.dosePerTime,
      doseUnit: formData.doseUnit,
      durationDays: formData.durationDays,
      startDate: formData.startDate ?? DateTime.now(),
      stockQuantity: formData.stockQuantity,
      remindBeforeRunOut: formData.remindBeforeRunOut,
      reminderDaysBeforeRunOut: formData.reminderDaysBeforeRunOut,
      customSoundPath: drift.Value(formData.customSoundPath),
      maxSnoozesPerDay: formData.maxSnoozesPerDay,
      updatedAt: DateTime.now(),
    );

    // Update medication
    final success = await _database.updateMedication(updated);

    // Update reminder times
    if (success) {
      final times = formData.reminderTimes
          .map((reminderData) => (
                hour: reminderData.time.hour,
                minute: reminderData.time.minute,
                mealTiming: reminderData.mealTiming.value,
                mealOffsetMinutes: reminderData.mealOffsetMinutes,
              ))
          .toList();
      await _database.updateReminderTimes(medicationId, times);

      // Reschedule notifications with new times
      try {
        final medication = await _database.getMedicationById(medicationId);
        if (medication != null) {
          final reminderTimes = await _database.getReminderTimes(medicationId);
          // Cancel old notifications and schedule new ones
          await _notificationService.scheduleRemindersForMedication(
            medication,
            reminderTimes,
          );
          debugPrint('Rescheduled notifications for medication $medicationId');
        }
      } catch (e) {
        debugPrint('Error rescheduling notifications: $e');
        // Don't fail the update if notification rescheduling fails
      }
    }

    return success;
  }

  /// Delete a medication (soft delete)
  Future<bool> deleteMedication(int id) async {
    final result = await _database.deleteMedication(id);

    // Cancel all notifications for this medication
    if (result > 0) {
      try {
        await _notificationService.cancelMedicationReminders(id);
        debugPrint('Cancelled notifications for medication $id');
      } catch (e) {
        debugPrint('Error cancelling notifications: $e');
        // Don't fail the delete if notification cancelling fails
      }
    }

    return result > 0;
  }

  /// Permanently delete a medication
  Future<bool> hardDeleteMedication(int id) async {
    final result = await _database.hardDeleteMedication(id);

    // Cancel all notifications for this medication
    if (result > 0) {
      try {
        await _notificationService.cancelMedicationReminders(id);
        debugPrint('Cancelled notifications for medication $id');
      } catch (e) {
        debugPrint('Error cancelling notifications: $e');
        // Don't fail the delete if notification cancelling fails
      }
    }

    return result > 0;
  }

  /// Convert database medication to form data
  Future<MedicationFormData> medicationToFormData(int medicationId) async {
    final medication = await _database.getMedicationById(medicationId);
    if (medication == null) {
      throw Exception('Medication not found');
    }

    final reminderTimes = await _database.getReminderTimes(medicationId);

    return MedicationFormData(
      medicineType: MedicineType.values.firstWhere(
        (type) => type.name == medication.medicineType,
      ),
      medicineName: medication.medicineName,
      medicinePhotoPath: medication.medicinePhotoPath,
      strength: medication.strength,
      unit: medication.unit,
      notes: medication.notes,
      isScanned: medication.isScanned,
      timesPerDay: medication.timesPerDay,
      dosePerTime: medication.dosePerTime,
      doseUnit: medication.doseUnit,
      durationDays: medication.durationDays,
      startDate: medication.startDate,
      reminderTimes: reminderTimes
          .map((rt) => ReminderTimeData(
                time: TimeOfDay(hour: rt.hour, minute: rt.minute),
                mealTiming: MealTiming.fromString(rt.mealTiming),
                mealOffsetMinutes: rt.mealOffsetMinutes,
              ))
          .toList(),
      stockQuantity: medication.stockQuantity,
      remindBeforeRunOut: medication.remindBeforeRunOut,
      reminderDaysBeforeRunOut: medication.reminderDaysBeforeRunOut,
      customSoundPath: medication.customSoundPath,
      maxSnoozesPerDay: medication.maxSnoozesPerDay,
    );
  }

  /// Get medication count
  Future<int> getMedicationCount() async {
    final meds = await _database.getAllMedications();
    return meds.length;
  }

  /// Check if any medications exist
  Future<bool> hasMedications() async {
    final count = await getMedicationCount();
    return count > 0;
  }

  /// Update stock quantity
  Future<bool> updateStockQuantity(int medicationId, int newQuantity) async {
    final medication = await _database.getMedicationById(medicationId);
    if (medication == null) return false;

    final updated = medication.copyWith(
      stockQuantity: newQuantity,
      updatedAt: DateTime.now(),
    );

    return _database.updateMedication(updated);
  }

  /// Record medication taken (decrease stock)
  Future<bool> recordMedicationTaken(int medicationId, double doseTaken) async {
    final medication = await _database.getMedicationById(medicationId);
    if (medication == null) return false;

    final newQuantity = (medication.stockQuantity - doseTaken).round();
    if (newQuantity < 0) return false;

    return updateStockQuantity(medicationId, newQuantity);
  }

  /// Close the database
  Future<void> close() {
    return _database.close();
  }
}
