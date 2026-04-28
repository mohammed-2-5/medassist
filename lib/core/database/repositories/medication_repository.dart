import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/models/dose_result.dart';
import 'package:med_assist/core/models/meal_timing.dart';
import 'package:med_assist/core/utils/drug_name_normalizer.dart';
import 'package:med_assist/core/utils/repetition_pattern_utils.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';
import 'package:med_assist/services/health/persisted_interaction_service.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// Repository for medication data operations.
///
/// All dose-recording and stock-mutation logic is centralised here so that
/// both the UI layer and the background notification handler share a single,
/// transactional code-path.
class MedicationRepository {
  MedicationRepository(this._database)
      : _persistedInteractions = PersistedInteractionService(_database);
  final AppDatabase _database;
  final NotificationService _notificationService = NotificationService();
  final PersistedInteractionService _persistedInteractions;

  // ---------------------------------------------------------------------------
  // Medication CRUD
  // ---------------------------------------------------------------------------

  Future<List<Medication>> getAllMedications() {
    return _database.getAllMedications();
  }

  Future<Medication?> getMedicationById(int id) {
    return _database.getMedicationById(id);
  }

  Future<List<Medication>> getTodaysMedications() {
    return _database.getTodaysMedications();
  }

  Future<List<MedicationWithReminders>> getMedicationsWithReminders() {
    return _database.getMedicationsWithReminders();
  }

  Future<List<Medication>> searchMedications(String query) {
    return _database.searchMedications(query);
  }

  Future<List<Medication>> getLowStockMedications() {
    return _database.getLowStockMedications();
  }

  Future<int> getMedicationCount() async {
    final meds = await _database.getAllMedications();
    return meds.length;
  }

  Future<bool> hasMedications() async {
    final count = await getMedicationCount();
    return count > 0;
  }

  Future<MedicationDrugInfoData?> getLocalizedDrugInfo({
    required int medicationId,
    required String language,
  }) {
    return _database.getMedicationDrugInfoByLanguage(medicationId, language);
  }

  Future<void> upsertLocalizedDrugInfo({
    required int medicationId,
    required String language,
    String? genericName,
    String? activeIngredients,
    String? drugCategory,
    String? purpose,
    String? howToTake,
    String? bestTimeOfDay,
    bool? drowsinessAffectsDriving,
    String? drowsinessWarning,
    String? foodsToAvoid,
    String? missedDoseAdvice,
    String? storageInstructions,
    String? sideEffects,
    String? warnings,
    String? route,
  }) {
    return _database.upsertMedicationDrugInfo(
      medicationId: medicationId,
      language: language,
      genericName: genericName,
      activeIngredients: activeIngredients,
      drugCategory: drugCategory,
      purpose: purpose,
      howToTake: howToTake,
      bestTimeOfDay: bestTimeOfDay,
      drowsinessAffectsDriving: drowsinessAffectsDriving,
      drowsinessWarning: drowsinessWarning,
      foodsToAvoid: foodsToAvoid,
      missedDoseAdvice: missedDoseAdvice,
      storageInstructions: storageInstructions,
      sideEffects: sideEffects,
      warnings: warnings,
      route: route,
    );
  }

  /// Find an existing medication matching name+strength+unit (normalized).
  /// Returns null if none found. Pass [excludeId] to ignore a specific row
  /// (useful in edit flows).
  Future<Medication?> findDuplicate({
    required String name,
    String? strength,
    String? unit,
    int? excludeId,
  }) async {
    final targetName = DrugNameNormalizer.canonicalName(name);
    if (targetName.isEmpty) return null;
    final targetStrength = DrugNameNormalizer.canonicalStrength(strength);
    final targetUnit = DrugNameNormalizer.canonicalUnit(unit);

    final all = await _database.getAllMedications();
    for (final med in all) {
      if (excludeId != null && med.id == excludeId) continue;
      if (DrugNameNormalizer.canonicalName(med.medicineName) != targetName) {
        continue;
      }
      if (DrugNameNormalizer.canonicalStrength(med.strength) !=
          targetStrength) {
        continue;
      }
      if (DrugNameNormalizer.canonicalUnit(med.unit) != targetUnit) continue;
      return med;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Save / Update / Delete medication
  // ---------------------------------------------------------------------------

  Future<int> saveMedication(MedicationFormData formData) async {
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
      repetitionPattern: drift.Value(formData.repetitionPattern.name),
      specificDaysOfWeek: drift.Value(formData.specificDaysOfWeek.join(',')),
      intervalDays: drift.Value(formData.intervalDays),
      intervalWeeks: drift.Value(formData.intervalWeeks),
      intervalMonths: drift.Value(formData.intervalMonths),
      dayOfMonth: drift.Value(formData.dayOfMonth),
      stockQuantity: drift.Value(formData.stockQuantity),
      remindBeforeRunOut: drift.Value(formData.remindBeforeRunOut),
      reminderDaysBeforeRunOut: drift.Value(formData.reminderDaysBeforeRunOut),
      customSoundPath: drift.Value(formData.customSoundPath),
      maxSnoozesPerDay: drift.Value(formData.maxSnoozesPerDay),
      genericName: drift.Value(formData.genericName),
      activeIngredients: drift.Value(formData.activeIngredients),
      drugCategory: drift.Value(formData.drugCategory),
      purpose: drift.Value(formData.purpose),
      sideEffects: drift.Value(formData.sideEffects),
      warnings: drift.Value(formData.drugWarnings),
      route: drift.Value(formData.drugRoute),
    );

    // Use transaction to ensure medication + reminder times are saved atomically
    final medicationId = await _database.transaction(() async {
      final id = await _database.insertMedication(companion);

      if (formData.reminderTimes.isNotEmpty) {
        final times = formData.reminderTimes
            .map(
              (r) => (
                hour: r.time.hour,
                minute: r.time.minute,
                mealTiming: r.mealTiming.value,
                mealOffsetMinutes: r.mealOffsetMinutes,
              ),
            )
            .toList();
        await _database.insertReminderTimes(id, times);
      }

      return id;
    });

    _scheduleNotifications(medicationId);

    return medicationId;
  }

  Future<bool> updateMedication(
    int medicationId,
    MedicationFormData formData,
  ) async {
    final existing = await _database.getMedicationById(medicationId);
    if (existing == null) return false;

    final updated = existing.copyWith(
      medicineType: formData.medicineType!.name,
      medicineName: formData.medicineName,
      medicinePhotoPath: drift.Value(formData.medicinePhotoPath),
      strength: drift.Value(formData.strength),
      unit: drift.Value(formData.unit),
      notes: drift.Value(formData.notes),
      isScanned: formData.isScanned,
      timesPerDay: formData.timesPerDay,
      dosePerTime: formData.dosePerTime,
      doseUnit: formData.doseUnit,
      durationDays: formData.durationDays,
      startDate: formData.startDate ?? DateTime.now(),
      repetitionPattern: formData.repetitionPattern.name,
      specificDaysOfWeek: formData.specificDaysOfWeek.join(','),
      intervalDays: drift.Value(formData.intervalDays),
      intervalWeeks: drift.Value(formData.intervalWeeks),
      intervalMonths: drift.Value(formData.intervalMonths),
      dayOfMonth: drift.Value(formData.dayOfMonth),
      stockQuantity: formData.stockQuantity,
      remindBeforeRunOut: formData.remindBeforeRunOut,
      reminderDaysBeforeRunOut: formData.reminderDaysBeforeRunOut,
      customSoundPath: drift.Value(formData.customSoundPath),
      maxSnoozesPerDay: formData.maxSnoozesPerDay,
      expiryDate: drift.Value(formData.expiryDate),
      reminderDaysBeforeExpiry: formData.reminderDaysBeforeExpiry,
      enableRecurringReminders: formData.enableRecurringReminders,
      recurringReminderInterval: formData.recurringReminderInterval,
      genericName: drift.Value(formData.genericName),
      activeIngredients: drift.Value(formData.activeIngredients),
      drugCategory: drift.Value(formData.drugCategory),
      purpose: drift.Value(formData.purpose),
      sideEffects: drift.Value(formData.sideEffects),
      warnings: drift.Value(formData.drugWarnings),
      route: drift.Value(formData.drugRoute),
      updatedAt: DateTime.now(),
    );

    final success = await _database.updateMedication(updated);

    if (success) {
      final times = formData.reminderTimes
          .map(
            (r) => (
              hour: r.time.hour,
              minute: r.time.minute,
              mealTiming: r.mealTiming.value,
              mealOffsetMinutes: r.mealOffsetMinutes,
            ),
          )
          .toList();
      await _database.updateReminderTimes(medicationId, times);
      _scheduleNotifications(medicationId);
    }

    return success;
  }

  Future<bool> deleteMedication(int id) async {
    final result = await _database.deleteMedication(id);
    if (result > 0) {
      try {
        await _notificationService.cancelMedicationReminders(id);
      } catch (e) {
        debugPrint('Error cancelling notifications: $e');
      }
      // Soft delete: FK cascade does not fire — clear interactions explicitly
      // so the warning vanishes from the surviving med.
      try {
        await _persistedInteractions.removeForMedication(id);
      } catch (e) {
        debugPrint('Error removing persisted interactions: $e');
      }
    }
    return result > 0;
  }

  Future<bool> hardDeleteMedication(int id) async {
    final result = await _database.hardDeleteMedication(id);
    if (result > 0) {
      try {
        await _notificationService.cancelMedicationReminders(id);
      } catch (e) {
        debugPrint('Error cancelling notifications: $e');
      }
    }
    return result > 0;
  }

  /// Persist interaction warnings the user accepted during the add flow.
  Future<void> persistAcceptedInteractions({
    required int newMedicationId,
    required List<InteractionWarning> warnings,
  }) async {
    await _persistedInteractions.persistAccepted(
      newMedicationId: newMedicationId,
      warnings: warnings,
    );
  }

  // ---------------------------------------------------------------------------
  // Dose operations — centralised, transactional
  // ---------------------------------------------------------------------------

  /// Record a dose as **taken**, deducting stock inside a single transaction.
  Future<DoseResult> takeDose({
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
  }) async {
    try {
      return await _database.transaction(() async {
        // 1. Prevent duplicates
        final existing = await _database.findDoseRecord(
          medicationId: medicationId,
          scheduledDate: scheduledDate,
          scheduledHour: scheduledHour,
          scheduledMinute: scheduledMinute,
        );

        if (existing != null && existing.status == 'taken') {
          return const DoseAlreadyRecorded();
        }

        final medication = await _database.getMedicationById(medicationId);
        if (medication == null) return const DoseMedicationNotFound();

        // 2. Remove stale record (e.g. snoozed) for the same slot
        if (existing != null) {
          await _database.deleteDoseRecord(
            medicationId: medicationId,
            scheduledDate: scheduledDate,
            scheduledHour: scheduledHour,
            scheduledMinute: scheduledMinute,
          );
        }

        // 3. Insert taken record
        await _database.recordDoseTaken(
          medicationId: medicationId,
          scheduledDate: scheduledDate,
          scheduledHour: scheduledHour,
          scheduledMinute: scheduledMinute,
        );

        // 4. Deduct stock with audit log
        String? stockWarning;
        final previousStock = medication.stockQuantity;

        if (previousStock > 0) {
          final newStock = (previousStock - medication.dosePerTime)
              .floor()
              .clamp(0, previousStock);
          await _updateStockWithLog(
            medicationId: medicationId,
            medication: medication,
            newStock: newStock,
            changeType: 'usage',
            notes: 'Dose taken',
          );

          if (newStock == 0) {
            stockWarning = '${medication.medicineName} is now out of stock';
          }
        } else {
          stockWarning = '${medication.medicineName} has no stock recorded';
        }

        return DoseRecorded(stockWarning: stockWarning);
      });
    } catch (e) {
      return DoseOperationFailed(e.toString());
    }
  }

  /// Record a dose as **skipped**.
  Future<DoseResult> skipDose({
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
  }) async {
    try {
      return await _database.transaction(() async {
        final existing = await _database.findDoseRecord(
          medicationId: medicationId,
          scheduledDate: scheduledDate,
          scheduledHour: scheduledHour,
          scheduledMinute: scheduledMinute,
        );

        if (existing != null && existing.status == 'skipped') {
          return const DoseAlreadyRecorded();
        }

        if (existing != null) {
          await _database.deleteDoseRecord(
            medicationId: medicationId,
            scheduledDate: scheduledDate,
            scheduledHour: scheduledHour,
            scheduledMinute: scheduledMinute,
          );
        }

        await _database.recordDoseSkipped(
          medicationId: medicationId,
          scheduledDate: scheduledDate,
          scheduledHour: scheduledHour,
          scheduledMinute: scheduledMinute,
        );

        return const DoseRecorded();
      });
    } catch (e) {
      return DoseOperationFailed(e.toString());
    }
  }

  /// Record a dose as **snoozed**.
  Future<DoseResult> snoozeDose({
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
    String? notes,
  }) async {
    try {
      return await _database.transaction(() async {
        final existing = await _database.findDoseRecord(
          medicationId: medicationId,
          scheduledDate: scheduledDate,
          scheduledHour: scheduledHour,
          scheduledMinute: scheduledMinute,
        );

        if (existing != null) {
          await _database.deleteDoseRecord(
            medicationId: medicationId,
            scheduledDate: scheduledDate,
            scheduledHour: scheduledHour,
            scheduledMinute: scheduledMinute,
          );
        }

        await _database.recordDoseSnoozed(
          medicationId: medicationId,
          scheduledDate: scheduledDate,
          scheduledHour: scheduledHour,
          scheduledMinute: scheduledMinute,
          notes: notes,
        );

        return const DoseRecorded();
      });
    } catch (e) {
      return DoseOperationFailed(e.toString());
    }
  }

  /// Undo a previously recorded dose, restoring stock if it was taken.
  Future<DoseResult> undoDose({
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
  }) async {
    try {
      return await _database.transaction(() async {
        final existing = await _database.findDoseRecord(
          medicationId: medicationId,
          scheduledDate: scheduledDate,
          scheduledHour: scheduledHour,
          scheduledMinute: scheduledMinute,
        );

        if (existing == null) return const DoseRecorded();

        // Restore stock if the dose was taken
        if (existing.status == 'taken') {
          final medication = await _database.getMedicationById(medicationId);
          if (medication != null) {
            final restoredStock =
                (medication.stockQuantity + medication.dosePerTime).floor();
            await _updateStockWithLog(
              medicationId: medicationId,
              medication: medication,
              newStock: restoredStock,
              changeType: 'adjustment',
              notes: 'Dose undone — stock restored',
            );
          }
        }

        await _database.deleteDoseRecord(
          medicationId: medicationId,
          scheduledDate: scheduledDate,
          scheduledHour: scheduledHour,
          scheduledMinute: scheduledMinute,
        );

        return const DoseRecorded();
      });
    } catch (e) {
      return DoseOperationFailed(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Stock helpers
  // ---------------------------------------------------------------------------

  Future<bool> updateStockQuantity(int medicationId, int newQuantity) async {
    final medication = await _database.getMedicationById(medicationId);
    if (medication == null) return false;

    final updated = medication.copyWith(
      stockQuantity: newQuantity,
      updatedAt: DateTime.now(),
    );
    return _database.updateMedication(updated);
  }

  /// Effective average daily usage accounting for the repetition pattern.
  static double effectiveDailyUsage(Medication medication) {
    final baseUsage = medication.timesPerDay * medication.dosePerTime;
    final daysPerWeek = RepetitionPatternUtils.doseDaysPerWeek(
      pattern: medication.repetitionPattern,
      specificDaysOfWeek: medication.specificDaysOfWeek,
      intervalDays: medication.intervalDays,
      intervalWeeks: medication.intervalWeeks,
      intervalMonths: medication.intervalMonths,
    );
    if (daysPerWeek <= 0) return 0;
    return baseUsage * daysPerWeek / 7;
  }

  // ---------------------------------------------------------------------------
  // Form conversion
  // ---------------------------------------------------------------------------

  Future<MedicationFormData> medicationToFormData(int medicationId) async {
    final medication = await _database.getMedicationById(medicationId);
    if (medication == null) {
      throw Exception('Medication not found');
    }

    final reminderTimes = await _database.getReminderTimes(medicationId);

    // Parse repetition pattern
    final repetitionPattern = RepetitionPattern.values.firstWhere(
      (p) => p.name == medication.repetitionPattern,
      orElse: () => RepetitionPattern.daily,
    );

    final specificDays = medication.specificDaysOfWeek
        .split(',')
        .where((d) => d.trim().isNotEmpty)
        .map((d) => int.tryParse(d.trim()))
        .whereType<int>()
        .toList();

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
      repetitionPattern: repetitionPattern,
      specificDaysOfWeek: specificDays,
      intervalDays: medication.intervalDays,
      intervalWeeks: medication.intervalWeeks,
      intervalMonths: medication.intervalMonths,
      dayOfMonth: medication.dayOfMonth,
      reminderTimes: reminderTimes
          .map(
            (rt) => ReminderTimeData(
              time: TimeOfDay(hour: rt.hour, minute: rt.minute),
              mealTiming: MealTiming.fromString(rt.mealTiming),
              mealOffsetMinutes: rt.mealOffsetMinutes,
            ),
          )
          .toList(),
      stockQuantity: medication.stockQuantity,
      remindBeforeRunOut: medication.remindBeforeRunOut,
      reminderDaysBeforeRunOut: medication.reminderDaysBeforeRunOut,
      customSoundPath: medication.customSoundPath,
      maxSnoozesPerDay: medication.maxSnoozesPerDay,
      genericName: medication.genericName,
      activeIngredients: medication.activeIngredients,
      drugCategory: medication.drugCategory,
      purpose: medication.purpose,
      sideEffects: medication.sideEffects,
      drugWarnings: medication.warnings,
      drugRoute: medication.route,
    );
  }

  Future<void> close() => _database.close();

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _updateStockWithLog({
    required int medicationId,
    required Medication medication,
    required int newStock,
    required String changeType,
    String? notes,
  }) async {
    final updated = medication.copyWith(
      stockQuantity: newStock,
      updatedAt: DateTime.now(),
    );
    await _database.updateMedication(updated);
    await _database.logStockChange(
      medicationId: medicationId,
      previousStock: medication.stockQuantity,
      newStock: newStock,
      changeType: changeType,
      notes: notes,
    );
  }

  Future<void> _scheduleNotifications(int medicationId) async {
    try {
      final medication = await _database.getMedicationById(medicationId);
      if (medication != null) {
        final reminderTimes = await _database.getReminderTimes(medicationId);
        await _notificationService.scheduleRemindersForMedication(
          medication,
          reminderTimes,
        );

        // Schedule expiry notification if expiry date is set
        if (medication.expiryDate != null) {
          await _notificationService.scheduleExpiryNotification(medication);
        }

        // Schedule low stock notification if applicable
        if (medication.remindBeforeRunOut) {
          await _notificationService.scheduleLowStockNotification(medication);
        }
      }
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }
}
