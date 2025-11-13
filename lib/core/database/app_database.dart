import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:med_assist/core/database/tables/dose_history_table.dart';
import 'package:med_assist/core/database/tables/medication_table.dart';
import 'package:med_assist/core/database/tables/snooze_history_table.dart';
import 'package:med_assist/core/database/tables/stock_history_table.dart';

part 'app_database.g.dart';

/// Main application database
@DriftDatabase(tables: [
  Medications,
  ReminderTimes,
  DoseHistory,
  StockHistory,
  SnoozeHistoryTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for testing with in-memory database
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migrate from version 1 to 2 (add dose history table)
        if (from == 1 && to >= 2) {
          await m.createTable(doseHistory);
        }

        // Migrate from version 2 to 3 (add stock history table and expiry fields)
        if (from <= 2 && to >= 3) {
          // Add stock history table
          await m.createTable(stockHistory);

          // Add expiry date and reminder columns to medications
          await m.addColumn(medications, medications.expiryDate);
          await m.addColumn(medications, medications.reminderDaysBeforeExpiry);
        }

        // Migrate from version 3 to 4 (add repetition pattern fields)
        if (from <= 3 && to >= 4) {
          // Add repetition pattern columns to medications
          await m.addColumn(medications, medications.repetitionPattern);
          await m.addColumn(medications, medications.specificDaysOfWeek);
        }

        // Migrate from version 4 to 5 (add advanced reminder features - Phase 2)
        if (from <= 4 && to >= 5) {
          // Add advanced reminder settings to medications
          await m.addColumn(medications, medications.customSoundPath);
          await m.addColumn(medications, medications.maxSnoozesPerDay);
          await m.addColumn(medications, medications.enableRecurringReminders);
          await m.addColumn(medications, medications.recurringReminderInterval);

          // Add meal timing options to reminder times
          await m.addColumn(reminderTimes, reminderTimes.mealTiming);
          await m.addColumn(reminderTimes, reminderTimes.mealOffsetMinutes);
        }

        // Migrate from version 5 to 6 (add snooze history tracking - Phase 2 Smart Snooze)
        if (from <= 5 && to >= 6) {
          // Create snooze history table
          await m.createTable(snoozeHistoryTable);
        }
      },
    );
  }

  // Medication CRUD operations

  /// Get all active medications
  Future<List<Medication>> getAllMedications() async {
    return (select(medications)
          ..where((tbl) => tbl.isActive.equals(true))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Get all medications including inactive (for backup)
  Future<List<Medication>> getAllMedicationsIncludingInactive() async {
    return (select(medications)
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Get a single medication by id
  Future<Medication?> getMedicationById(int id) async {
    return (select(medications)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Get medications for today
  Future<List<Medication>> getTodaysMedications() async {
    final now = DateTime.now();
    return (select(medications)
          ..where((tbl) => tbl.isActive.equals(true))
          ..where((tbl) => tbl.startDate.isSmallerOrEqualValue(now)))
        .get();
  }

  /// Insert a new medication
  Future<int> insertMedication(MedicationsCompanion medication) async {
    return into(medications).insert(medication);
  }

  /// Update an existing medication
  Future<bool> updateMedication(Medication medication) async {
    return update(medications).replace(medication);
  }

  /// Soft delete medication (set isActive to false)
  Future<int> deleteMedication(int id) async {
    return (update(medications)..where((tbl) => tbl.id.equals(id)))
        .write(const MedicationsCompanion(isActive: Value(false)));
  }

  /// Hard delete medication (actually remove from database)
  Future<int> hardDeleteMedication(int id) async {
    return (delete(medications)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Reminder Times CRUD operations

  /// Get reminder times for a medication
  Future<List<ReminderTime>> getReminderTimes(int medicationId) async {
    return (select(reminderTimes)
          ..where((tbl) => tbl.medicationId.equals(medicationId))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.orderIndex),
          ]))
        .get();
  }

  /// Insert reminder times for a medication
  Future<void> insertReminderTimes(
    int medicationId,
    List<({int hour, int minute, String mealTiming, int mealOffsetMinutes})> times,
  ) async {
    await batch((batch) {
      batch.insertAll(
        reminderTimes,
        times
            .asMap()
            .entries
            .map(
              (entry) => ReminderTimesCompanion.insert(
                medicationId: medicationId,
                hour: entry.value.hour,
                minute: entry.value.minute,
                orderIndex: entry.key,
                mealTiming: Value(entry.value.mealTiming),
                mealOffsetMinutes: Value(entry.value.mealOffsetMinutes),
              ),
            )
            .toList(),
      );
    });
  }

  /// Delete all reminder times for a medication
  Future<int> deleteReminderTimes(int medicationId) async {
    return (delete(reminderTimes)
          ..where((tbl) => tbl.medicationId.equals(medicationId)))
        .go();
  }

  /// Update reminder times for a medication
  Future<void> updateReminderTimes(
    int medicationId,
    List<({int hour, int minute, String mealTiming, int mealOffsetMinutes})> times,
  ) async {
    await transaction(() async {
      await deleteReminderTimes(medicationId);
      await insertReminderTimes(medicationId, times);
    });
  }

  // Complex queries

  /// Get medications with their reminder times
  Future<List<MedicationWithReminders>> getMedicationsWithReminders() async {
    final meds = await getAllMedications();
    final result = <MedicationWithReminders>[];

    for (final med in meds) {
      final times = await getReminderTimes(med.id);
      result.add(MedicationWithReminders(medication: med, reminderTimes: times));
    }

    return result;
  }

  /// Search medications by name
  Future<List<Medication>> searchMedications(String query) async {
    return (select(medications)
          ..where((tbl) => tbl.medicineName.like('%$query%'))
          ..where((tbl) => tbl.isActive.equals(true)))
        .get();
  }

  /// Get medications that are running low on stock
  Future<List<Medication>> getLowStockMedications() async {
    // Get all active medications and filter in Dart
    final allMeds = await getAllMedications();
    return allMeds.where((med) {
      if (med.stockQuantity <= 0 || med.timesPerDay <= 0) return false;
      final dailyUsage = med.dosePerTime * med.timesPerDay;
      final daysRemaining = (med.stockQuantity / dailyUsage).floor();
      return daysRemaining <= med.reminderDaysBeforeRunOut;
    }).toList();
  }

  // Dose History CRUD operations

  /// Record a dose as taken
  Future<int> recordDoseTaken({
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
    DateTime? actualTime,
    String? notes,
  }) async {
    return into(doseHistory).insert(
      DoseHistoryCompanion.insert(
        medicationId: medicationId,
        scheduledDate: scheduledDate,
        scheduledHour: scheduledHour,
        scheduledMinute: scheduledMinute,
        status: 'taken',
        actualTime: Value(actualTime ?? DateTime.now()),
        notes: Value(notes),
      ),
    );
  }

  /// Record a dose as skipped
  Future<int> recordDoseSkipped({
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
    String? notes,
  }) async {
    return into(doseHistory).insert(
      DoseHistoryCompanion.insert(
        medicationId: medicationId,
        scheduledDate: scheduledDate,
        scheduledHour: scheduledHour,
        scheduledMinute: scheduledMinute,
        status: 'skipped',
        notes: Value(notes),
      ),
    );
  }

  /// Record a dose as snoozed
  Future<int> recordDoseSnoozed({
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
    String? notes,
  }) async {
    return into(doseHistory).insert(
      DoseHistoryCompanion.insert(
        medicationId: medicationId,
        scheduledDate: scheduledDate,
        scheduledHour: scheduledHour,
        scheduledMinute: scheduledMinute,
        status: 'snoozed',
        notes: Value(notes),
      ),
    );
  }

  /// Get dose history for a medication
  Future<List<DoseHistoryData>> getDoseHistory(int medicationId) async {
    return (select(doseHistory)
          ..where((tbl) => tbl.medicationId.equals(medicationId))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.scheduledDate, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Get dose history for a date
  Future<List<DoseHistoryData>> getDoseHistoryForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(doseHistory)
          ..where((tbl) => tbl.scheduledDate.isBiggerOrEqualValue(startOfDay))
          ..where((tbl) => tbl.scheduledDate.isSmallerThanValue(endOfDay)))
        .get();
  }

  /// Check if dose was already recorded
  Future<DoseHistoryData?> findDoseRecord({
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
  }) async {
    final startOfDay = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(doseHistory)
          ..where((tbl) => tbl.medicationId.equals(medicationId))
          ..where((tbl) => tbl.scheduledDate.isBiggerOrEqualValue(startOfDay))
          ..where((tbl) => tbl.scheduledDate.isSmallerThanValue(endOfDay))
          ..where((tbl) => tbl.scheduledHour.equals(scheduledHour))
          ..where((tbl) => tbl.scheduledMinute.equals(scheduledMinute)))
        .getSingleOrNull();
  }

  /// Get adherence statistics for a date range
  Future<Map<String, int>> getAdherenceStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final records = await (select(doseHistory)
          ..where((tbl) => tbl.scheduledDate.isBiggerOrEqualValue(startDate))
          ..where((tbl) => tbl.scheduledDate.isSmallerOrEqualValue(endDate)))
        .get();

    final stats = <String, int>{
      'taken': 0,
      'skipped': 0,
      'missed': 0,
      'snoozed': 0,
    };

    for (final record in records) {
      stats[record.status] = (stats[record.status] ?? 0) + 1;
    }

    return stats;
  }

  /// Delete a specific dose history record (for undo functionality)
  Future<int> deleteDoseRecord({
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
  }) async {
    final startOfDay = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (delete(doseHistory)
          ..where((tbl) => tbl.medicationId.equals(medicationId))
          ..where((tbl) => tbl.scheduledDate.isBiggerOrEqualValue(startOfDay))
          ..where((tbl) => tbl.scheduledDate.isSmallerThanValue(endOfDay))
          ..where((tbl) => tbl.scheduledHour.equals(scheduledHour))
          ..where((tbl) => tbl.scheduledMinute.equals(scheduledMinute)))
        .go();
  }

  /// Get all dose history (for analytics and history screens)
  Future<List<DoseHistoryData>> getAllDoseHistory() async {
    return (select(doseHistory)
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.scheduledDate, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Get active medications (alias for getAllMedications since it already filters active)
  Future<List<Medication>> getActiveMedications() async {
    return getAllMedications();
  }

  /// Update a dose history record
  Future<bool> updateDoseHistory(DoseHistoryData doseHistory) async {
    return update(this.doseHistory).replace(doseHistory);
  }

  /// Update medication stock quantity directly
  Future<bool> updateMedicationStock(int medicationId, int newStock) async {
    final medication = await getMedicationById(medicationId);
    if (medication == null) return false;

    final updated = medication.copyWith(
      stockQuantity: newStock,
      updatedAt: DateTime.now(),
    );

    return updateMedication(updated);
  }

  /// Record a dose as missed
  Future<int> recordDoseMissed({
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
    String? notes,
  }) async {
    return into(doseHistory).insert(
      DoseHistoryCompanion.insert(
        medicationId: medicationId,
        scheduledDate: scheduledDate,
        scheduledHour: scheduledHour,
        scheduledMinute: scheduledMinute,
        status: 'missed',
        notes: Value(notes),
      ),
    );
  }

  // Stock History CRUD operations

  /// Log a stock change
  Future<int> logStockChange({
    required int medicationId,
    required int previousStock,
    required int newStock,
    required String changeType,
    String? notes,
  }) async {
    final changeAmount = newStock - previousStock;

    return into(stockHistory).insert(
      StockHistoryCompanion.insert(
        medicationId: medicationId,
        previousStock: previousStock,
        newStock: newStock,
        changeAmount: changeAmount,
        changeType: changeType,
        notes: Value(notes),
      ),
    );
  }

  /// Get stock history for a medication
  Future<List<StockHistoryData>> getStockHistory(int medicationId) async {
    return (select(stockHistory)
          ..where((tbl) => tbl.medicationId.equals(medicationId))
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.changeDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  /// Update medication stock with logging
  Future<bool> updateMedicationStockWithLog({
    required int medicationId,
    required int newStock,
    required String changeType,
    String? notes,
  }) async {
    final medication = await getMedicationById(medicationId);
    if (medication == null) return false;

    final previousStock = medication.stockQuantity;

    // Update stock
    final updated = medication.copyWith(
      stockQuantity: newStock,
      updatedAt: DateTime.now(),
    );

    final success = await updateMedication(updated);

    if (success) {
      // Log the change
      await logStockChange(
        medicationId: medicationId,
        previousStock: previousStock,
        newStock: newStock,
        changeType: changeType,
        notes: notes,
      );
    }

    return success;
  }

  /// Get medications expiring soon
  Future<List<Medication>> getExpiringMedications({int daysAhead = 30}) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: daysAhead));

    final allMeds = await getAllMedications();
    return allMeds.where((med) {
      if (med.expiryDate == null) return false;
      return med.expiryDate!.isAfter(now) &&
          med.expiryDate!.isBefore(futureDate);
    }).toList();
  }

  /// Get expired medications
  Future<List<Medication>> getExpiredMedications() async {
    final now = DateTime.now();

    final allMeds = await getAllMedications();
    return allMeds.where((med) {
      if (med.expiryDate == null) return false;
      return med.expiryDate!.isBefore(now);
    }).toList();
  }

  // Snooze History CRUD operations

  /// Get today's snooze count for a medication
  Future<SnoozeHistoryData?> getTodaySnoozeHistory(int medicationId) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return (select(snoozeHistoryTable)
          ..where((tbl) =>
              tbl.medicationId.equals(medicationId) &
              tbl.snoozeDate.equals(todayDate)))
        .getSingleOrNull();
  }

  /// Increment snooze count for today
  Future<void> incrementSnoozeCount({
    required int medicationId,
    required int suggestedMinutes,
  }) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final existing = await getTodaySnoozeHistory(medicationId);

    if (existing != null) {
      // Update existing record
      await (update(snoozeHistoryTable)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        SnoozeHistoryTableCompanion(
          snoozeCount: Value(existing.snoozeCount + 1),
          lastSnoozeTime: Value(DateTime.now()),
          suggestedMinutes: Value(suggestedMinutes),
        ),
      );
    } else {
      // Create new record for today
      await into(snoozeHistoryTable).insert(
        SnoozeHistoryTableCompanion.insert(
          medicationId: medicationId,
          snoozeDate: todayDate,
          snoozeCount: const Value(1),
          lastSnoozeTime: DateTime.now(),
          suggestedMinutes: Value(suggestedMinutes),
        ),
      );
    }
  }

  /// Reset snooze count (call at midnight)
  Future<void> resetOldSnoozeHistory() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Delete snooze records older than today
    await (delete(snoozeHistoryTable)
          ..where((tbl) => tbl.snoozeDate.isSmallerThanValue(todayDate)))
        .go();
  }

  /// Get snooze statistics for a medication
  Future<Map<String, dynamic>> getSnoozeStats(int medicationId) async {
    final history = await (select(snoozeHistoryTable)
          ..where((tbl) => tbl.medicationId.equals(medicationId))
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.snoozeDate,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(30))
        .get();

    if (history.isEmpty) {
      return {
        'totalSnoozes': 0,
        'averagePerDay': 0.0,
        'maxInDay': 0,
        'daysWithSnoozes': 0,
      };
    }

    final totalSnoozes = history.fold<int>(
      0,
      (sum, record) => sum + record.snoozeCount,
    );

    final maxInDay = history
        .map((record) => record.snoozeCount)
        .reduce((a, b) => a > b ? a : b);

    return {
      'totalSnoozes': totalSnoozes,
      'averagePerDay': totalSnoozes / history.length,
      'maxInDay': maxInDay,
      'daysWithSnoozes': history.length,
    };
  }

  // Backup & Restore Methods

  /// Get all stock history (for backup)
  Future<List<StockHistoryData>> getAllStockHistory() async {
    return (select(stockHistory)
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.changeDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  /// Get all snooze history (for backup)
  Future<List<SnoozeHistoryData>> getAllSnoozeHistory() async {
    return (select(snoozeHistoryTable)
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.snoozeDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  /// Clear all data (for restore)
  Future<void> clearAllData() async {
    await transaction(() async {
      // Delete in correct order (respecting foreign keys)
      await delete(snoozeHistoryTable).go();
      await delete(doseHistory).go();
      await delete(stockHistory).go();
      await delete(reminderTimes).go();
      await delete(medications).go();
    });
  }

  /// Insert dose history (for restore)
  Future<int> insertDoseHistory(DoseHistoryCompanion entry) async {
    return into(doseHistory).insert(entry);
  }

  /// Insert snooze history (for restore)
  Future<int> insertSnoozeHistory(SnoozeHistoryTableCompanion entry) async {
    return into(snoozeHistoryTable).insert(entry);
  }

  /// Insert stock history (for restore)
  Future<int> insertStockHistory(StockHistoryCompanion entry) async {
    return into(stockHistory).insert(entry);
  }
}

/// Combined medication with its reminder times
class MedicationWithReminders {

  MedicationWithReminders({
    required this.medication,
    required this.reminderTimes,
  });
  final Medication medication;
  final List<ReminderTime> reminderTimes;
}

/// Open database connection
QueryExecutor _openConnection() {
  return driftDatabase(name: 'med_assist_db');
}
