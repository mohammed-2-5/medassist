import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/core/database/app_database.dart';

import 'helpers/test_helpers.dart';

/// Integration Tests for Dose Taking Flow
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    final meds = await db.getAllMedicationsIncludingInactive();
    for (final med in meds) {
      await db.hardDeleteMedication(med.id);
    }
    await cleanupDatabase(db);
  });

  group('Dose Recording - Taken', () {
    test('User can mark dose as taken', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Aspirin'),
      );

      final scheduledDate = DateTime.now();
      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: scheduledDate.add(const Duration(minutes: 5)),
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(1));
      expect(history.first.status, equals('taken'));
      expect(history.first.scheduledHour, equals(8));
      expect(history.first.scheduledMinute, equals(0));
    });

    test('Dose is recorded in history when taken', () async {
      final medId = await db.insertMedication(
        createTestMedication(
          name: 'Ibuprofen',
          dosePerTime: 2,
        ),
      );

      final scheduledDate = DateTime.now();
      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: scheduledDate,
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(1));
      expect(history.first.status, equals('taken'));
      expect(history.first.actualTime, isNotNull);
    });

    test('User can take dose early', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Morning Med'),
      );

      final scheduledDate = DateTime.now();
      final actualTime = scheduledDate.subtract(const Duration(minutes: 30));

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: actualTime,
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(1));
      expect(history.first.status, equals('taken'));
      expect(history.first.actualTime, isNotNull);
      expect(history.first.actualTime!.isBefore(scheduledDate), isTrue);
    });

    test('User can take dose late', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Evening Med'),
      );

      final scheduledDate = DateTime.now();
      final actualTime = scheduledDate.add(const Duration(hours: 2));

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 20,
        scheduledMinute: 0,
        actualTime: actualTime,
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(1));
      expect(history.first.status, equals('taken'));
      expect(history.first.actualTime!.isAfter(scheduledDate), isTrue);
    });

    test('Multiple doses can be recorded for same medication', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Multi-dose Med'),
      );

      final today = DateTime.now();

      // Morning dose
      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      // Evening dose
      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 20,
        scheduledMinute: 0,
        actualTime: today.add(const Duration(hours: 12)),
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(2));
      expect(history.where((d) => d.status == 'taken').length, equals(2));
    });
  });

  group('Dose Recording - Skipped', () {
    test('User can mark dose as skipped', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Skipped Med'),
      );

      final scheduledDate = DateTime.now();
      await db.recordDoseSkipped(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
        notes: 'Forgot to take',
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(1));
      expect(history.first.status, equals('skipped'));
      expect(history.first.notes, equals('Forgot to take'));
    });

    test('Skipping dose does not update stock quantity', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Med'),
      );

      final scheduledDate = DateTime.now();
      await db.recordDoseSkipped(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
      );

      final med = await db.getMedicationById(medId);
      expect(med!.stockQuantity, equals(30)); // Unchanged
    });

    test('User can skip dose with notes', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Med'),
      );

      final scheduledDate = DateTime.now();
      await db.recordDoseSkipped(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
        notes: 'Side effects',
      );

      final history = await db.getDoseHistory(medId);
      expect(history.first.notes, equals('Side effects'));
    });

    test('User can skip dose without reason', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Med'),
      );

      final scheduledDate = DateTime.now();
      await db.recordDoseSkipped(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
      );

      final history = await db.getDoseHistory(medId);
      expect(history.first.status, equals('skipped'));
      expect(history.first.notes, isNull);
    });
  });

  group('Dose Recording - Snoozed', () {
    test('User can snooze a dose', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Snoozed Med'),
      );

      final scheduledDate = DateTime.now();
      await db.recordDoseSnoozed(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
        notes: 'Snoozed for 15 minutes',
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(1));
      expect(history.first.status, equals('snoozed'));
    });

    test('Snoozing dose does not update stock quantity', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Med'),
      );

      final scheduledDate = DateTime.now();
      await db.recordDoseSnoozed(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
      );

      final med = await db.getMedicationById(medId);
      expect(med!.stockQuantity, equals(30)); // Unchanged
    });

    test('User can snooze dose multiple times', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Multi-snooze Med'),
      );

      final scheduledDate = DateTime.now();

      // First snooze
      await db.recordDoseSnoozed(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
        notes: 'First snooze',
      );

      // Second snooze
      await db.recordDoseSnoozed(
        medicationId: medId,
        scheduledDate: scheduledDate,
        scheduledHour: 8,
        scheduledMinute: 0,
        notes: 'Second snooze',
      );

      final history = await db.getDoseHistory(medId);
      expect(history.where((d) => d.status == 'snoozed').length, equals(2));
    });
  });

  group('Dose History Retrieval', () {
    test('User can view complete dose history', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Med'),
      );

      final today = DateTime.now();

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      await db.recordDoseSkipped(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 14,
        scheduledMinute: 0,
      );

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 20,
        scheduledMinute: 0,
        actualTime: today.add(const Duration(hours: 12)),
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(3));
      expect(history.where((d) => d.status == 'taken').length, equals(2));
      expect(history.where((d) => d.status == 'skipped').length, equals(1));
    });

    test('User can view dose history for specific date', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Med'),
      );

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // Today's dose
      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      // Yesterday's dose
      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: yesterday,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: yesterday,
      );

      final todayHistory = await db.getDoseHistoryForDate(today);
      expect(todayHistory.length, greaterThanOrEqualTo(1));
      expect(todayHistory.any((d) => d.medicationId == medId), isTrue);
    });

    test('Dose history is ordered by scheduled date (descending)', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Med'),
      );

      final today = DateTime.now();

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 20,
        scheduledMinute: 0,
        actualTime: today,
      );

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 14,
        scheduledMinute: 0,
        actualTime: today,
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(3));
      // History is ordered by date descending (newest first)
      expect(history[0].scheduledHour, greaterThanOrEqualTo(history[1].scheduledHour));
    });

    test('Empty medication has no dose history', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'New Med'),
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(0));
    });
  });


  group('Complex Dose Scenarios', () {
    test('Complete daily medication workflow', () async {
      final medId = await db.insertMedication(
        createTestMedication(
          name: 'Daily Med',
          timesPerDay: 3,
        ),
      );

      final today = DateTime.now();

      // Morning - taken on time
      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      // Afternoon - taken late
      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 14,
        scheduledMinute: 0,
        actualTime: today.add(const Duration(hours: 7)),
      );

      // Evening - skipped
      await db.recordDoseSkipped(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 20,
        scheduledMinute: 0,
        notes: 'Fell asleep',
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(3));

      final takenCount = history.where((d) => d.status == 'taken').length;
      final skippedCount = history.where((d) => d.status == 'skipped').length;

      expect(takenCount, equals(2));
      expect(skippedCount, equals(1));
    });

    test('Week-long dose tracking', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Weekly Med'),
      );

      // Record doses for 7 days
      for (var day = 0; day < 7; day++) {
        final date = DateTime.now().subtract(Duration(days: day));

        await db.recordDoseTaken(
          medicationId: medId,
          scheduledDate: date,
          scheduledHour: 8,
          scheduledMinute: 0,
          actualTime: date,
        );
      }

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(7));
      expect(history.where((d) => d.status == 'taken').length, equals(7));
    });

    test('Mixed status dose history', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Mixed Med'),
      );

      final today = DateTime.now();

      // Create varied history over a week
      for (var day = 0; day <= 6; day++) {
        final date = today.subtract(Duration(days: day));

        if (day % 3 == 0) {
          await db.recordDoseTaken(
            medicationId: medId,
            scheduledDate: date,
            scheduledHour: 8,
            scheduledMinute: 0,
            actualTime: date,
          );
        } else if (day % 3 == 1) {
          await db.recordDoseSkipped(
            medicationId: medId,
            scheduledDate: date,
            scheduledHour: 8,
            scheduledMinute: 0,
          );
        } else {
          await db.recordDoseSnoozed(
            medicationId: medId,
            scheduledDate: date,
            scheduledHour: 8,
            scheduledMinute: 0,
            notes: 'Snoozed',
          );
        }
      }

      final history = await db.getDoseHistory(medId);

      expect(history.length, equals(7));
      expect(history.where((d) => d.status == 'taken').length, equals(3));
      expect(history.where((d) => d.status == 'skipped').length, equals(2));
      expect(history.where((d) => d.status == 'snoozed').length, equals(2));
    });
  });
}
