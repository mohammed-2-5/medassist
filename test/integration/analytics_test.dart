import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/core/database/app_database.dart';

import 'helpers/test_helpers.dart';

/// Integration Tests for Analytics & Dashboard Flow
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

  group('Adherence Statistics', () {
    test('Calculate adherence stats for date range', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Test Med'),
      );

      final today = DateTime.now();
      final weekAgo = today.subtract(const Duration(days: 7));

      // Record varied doses
      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      await db.recordDoseSkipped(
        medicationId: medId,
        scheduledDate: today.subtract(const Duration(days: 1)),
        scheduledHour: 8,
        scheduledMinute: 0,
      );

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today.subtract(const Duration(days: 2)),
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today.subtract(const Duration(days: 2)),
      );

      final stats = await db.getAdherenceStats(weekAgo, today);

      expect(stats['taken'], equals(2));
      expect(stats['skipped'], equals(1));
    });

    test('Calculate adherence percentage correctly', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Med'),
      );

      final today = DateTime.now();

      // 3 taken, 1 skipped, 1 snoozed = 5 total, 60% adherence
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
        scheduledHour: 12,
        scheduledMinute: 0,
        actualTime: today,
      );

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 16,
        scheduledMinute: 0,
        actualTime: today,
      );

      await db.recordDoseSkipped(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 20,
        scheduledMinute: 0,
      );

      await db.recordDoseSnoozed(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 21,
        scheduledMinute: 0,
      );

      final adherence = await calculateTestAdherence(db, medId);
      expect(adherence, equals(60.0)); // 3/5 * 100
    });

    test('Handle perfect adherence (100%)', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Perfect Med'),
      );

      final today = DateTime.now();

      for (final hour in [8, 12, 16, 20]) {
        await db.recordDoseTaken(
          medicationId: medId,
          scheduledDate: today,
          scheduledHour: hour,
          scheduledMinute: 0,
          actualTime: today,
        );
      }

      final adherence = await calculateTestAdherence(db, medId);
      expect(adherence, equals(100.0));
    });

    test('Handle zero adherence (all skipped)', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Skipped Med'),
      );

      final today = DateTime.now();

      for (final hour in [8, 12, 16, 20]) {
        await db.recordDoseSkipped(
          medicationId: medId,
          scheduledDate: today,
          scheduledHour: hour,
          scheduledMinute: 0,
        );
      }

      final adherence = await calculateTestAdherence(db, medId);
      expect(adherence, equals(0.0));
    });

    test('Handle empty dose history gracefully', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'New Med'),
      );

      final adherence = await calculateTestAdherence(db, medId);
      expect(adherence, equals(0.0));
    });
  });

  group('Dose History Analytics', () {
    test('Count total doses for medication', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Med'),
      );

      final today = DateTime.now();

      for (var i = 0; i < 10; i++) {
        await db.recordDoseTaken(
          medicationId: medId,
          scheduledDate: today.subtract(Duration(days: i)),
          scheduledHour: 8,
          scheduledMinute: 0,
          actualTime: today.subtract(Duration(days: i)),
        );
      }

      final count = await countTotalDoses(db, medId);
      expect(count, equals(10));
    });

    test('Get all dose history across all medications', () async {
      final med1Id = await db.insertMedication(
        createTestMedication(name: 'Med 1'),
      );

      final med2Id = await db.insertMedication(
        createTestMedication(name: 'Med 2'),
      );

      final today = DateTime.now();

      await db.recordDoseTaken(
        medicationId: med1Id,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      await db.recordDoseTaken(
        medicationId: med2Id,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      final allHistory = await db.getAllDoseHistory();
      expect(allHistory.length, greaterThanOrEqualTo(2));
    });

    test('Filter dose history by status', () async {
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
        scheduledHour: 12,
        scheduledMinute: 0,
      );

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 16,
        scheduledMinute: 0,
        actualTime: today,
      );

      final history = await db.getDoseHistory(medId);
      final takenDoses = history.where((d) => d.status == 'taken').toList();
      final skippedDoses = history.where((d) => d.status == 'skipped').toList();

      expect(takenDoses.length, equals(2));
      expect(skippedDoses.length, equals(1));
    });
  });

  group('Complex Medication Data', () {
    test('Build medication context string for analytics', () async {
      final meds = [
        await db.getMedicationById(
          await db.insertMedication(
            createTestMedication(name: 'Aspirin'),
          ),
        ),
        await db.getMedicationById(
          await db.insertMedication(
            createTestMedication(name: 'Lisinopril', strength: '10', timesPerDay: 1),
          ),
        ),
      ];

      final context = buildMedicationContext(
        meds.where((m) => m != null).cast<Medication>().toList(),
      );

      expect(context, contains('Aspirin'));
      expect(context, contains('500mg'));
      expect(context, contains('2x per day'));
      expect(context, contains('Lisinopril'));
    });

    test('Handle empty medication list in context', () async {
      final context = buildMedicationContext([]);
      expect(context, contains('No medications'));
    });

    test('Compare medications for equality', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Test Med', strength: '100'),
      );

      final med1 = await db.getMedicationById(medId);
      final med2 = await db.getMedicationById(medId);

      expect(medicationsEqual(med1!, med2!), isTrue);
    });

    test('Detect medication differences', () async {
      final med1Id = await db.insertMedication(
        createTestMedication(name: 'Med 1'),
      );

      final med2Id = await db.insertMedication(
        createTestMedication(name: 'Med 2'),
      );

      final med1 = await db.getMedicationById(med1Id);
      final med2 = await db.getMedicationById(med2Id);

      expect(medicationsEqual(med1!, med2!), isFalse);
    });
  });

  group('Date Range Analytics', () {
    test('Get adherence stats for specific week', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Weekly Med'),
      );

      final today = DateTime.now();
      final weekStart = today.subtract(const Duration(days: 6));

      // Create a week of varied history
      for (var day = 0; day < 7; day++) {
        final date = weekStart.add(Duration(days: day));

        if (day % 2 == 0) {
          await db.recordDoseTaken(
            medicationId: medId,
            scheduledDate: date,
            scheduledHour: 8,
            scheduledMinute: 0,
            actualTime: date,
          );
        } else {
          await db.recordDoseSkipped(
            medicationId: medId,
            scheduledDate: date,
            scheduledHour: 8,
            scheduledMinute: 0,
          );
        }
      }

      final stats = await db.getAdherenceStats(weekStart, today);

      expect(stats['taken'], equals(4)); // Days 0, 2, 4, 6
      expect(stats['skipped'], equals(3)); // Days 1, 3, 5
    });

    test('Get adherence stats for specific month', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Monthly Med'),
      );

      final today = DateTime.now();
      final monthStart = DateTime(today.year, today.month);
      final monthEnd = DateTime(today.year, today.month + 1, 0);

      // Record some doses
      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: monthStart.add(const Duration(days: 5)),
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: monthStart.add(const Duration(days: 5)),
      );

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: monthStart.add(const Duration(days: 10)),
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: monthStart.add(const Duration(days: 10)),
      );

      final stats = await db.getAdherenceStats(monthStart, monthEnd);

      expect(stats['taken'], greaterThanOrEqualTo(2));
    });

    test('Get dose history for specific date only', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Med'),
      );

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: yesterday,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: yesterday,
      );

      final todayDoses = await db.getDoseHistoryForDate(today);

      expect(todayDoses.length, greaterThanOrEqualTo(1));
      expect(todayDoses.any((d) => d.medicationId == medId && d.scheduledDate.day == today.day), isTrue);
    });
  });

  group('Multi-Medication Analytics', () {
    test('Track adherence across multiple medications', () async {
      final med1Id = await db.insertMedication(
        createTestMedication(name: 'Med 1'),
      );

      final med2Id = await db.insertMedication(
        createTestMedication(name: 'Med 2'),
      );

      final today = DateTime.now();

      // Med 1: perfect adherence
      await db.recordDoseTaken(
        medicationId: med1Id,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      await db.recordDoseTaken(
        medicationId: med1Id,
        scheduledDate: today,
        scheduledHour: 20,
        scheduledMinute: 0,
        actualTime: today,
      );

      // Med 2: partial adherence
      await db.recordDoseTaken(
        medicationId: med2Id,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );

      await db.recordDoseSkipped(
        medicationId: med2Id,
        scheduledDate: today,
        scheduledHour: 20,
        scheduledMinute: 0,
      );

      final adherence1 = await calculateTestAdherence(db, med1Id);
      final adherence2 = await calculateTestAdherence(db, med2Id);

      expect(adherence1, equals(100.0));
      expect(adherence2, equals(50.0));
    });

    test('Get combined dose history for all medications', () async {
      await createMultipleTestMedications(db, 3);

      final allMeds = await db.getAllMedications();
      final today = DateTime.now();

      for (final med in allMeds) {
        await db.recordDoseTaken(
          medicationId: med.id,
          scheduledDate: today,
          scheduledHour: 8,
          scheduledMinute: 0,
          actualTime: today,
        );
      }

      final allHistory = await db.getAllDoseHistory();
      expect(allHistory.length, greaterThanOrEqualTo(3));
    });

    test('Compare adherence between medications', () async {
      final goodMedId = await db.insertMedication(
        createTestMedication(name: 'Good Med'),
      );

      final poorMedId = await db.insertMedication(
        createTestMedication(name: 'Poor Med'),
      );

      final today = DateTime.now();

      // Good medication: 4/5 taken = 80%
      for (var i = 0; i < 4; i++) {
        await db.recordDoseTaken(
          medicationId: goodMedId,
          scheduledDate: today.subtract(Duration(days: i)),
          scheduledHour: 8,
          scheduledMinute: 0,
          actualTime: today.subtract(Duration(days: i)),
        );
      }
      await db.recordDoseSkipped(
        medicationId: goodMedId,
        scheduledDate: today.subtract(const Duration(days: 4)),
        scheduledHour: 8,
        scheduledMinute: 0,
      );

      // Poor medication: 1/5 taken = 20%
      await db.recordDoseTaken(
        medicationId: poorMedId,
        scheduledDate: today,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: today,
      );
      for (var i = 1; i < 5; i++) {
        await db.recordDoseSkipped(
          medicationId: poorMedId,
          scheduledDate: today.subtract(Duration(days: i)),
          scheduledHour: 8,
          scheduledMinute: 0,
        );
      }

      final goodAdherence = await calculateTestAdherence(db, goodMedId);
      final poorAdherence = await calculateTestAdherence(db, poorMedId);

      expect(goodAdherence, greaterThan(poorAdherence));
      expect(goodAdherence, equals(80.0));
      expect(poorAdherence, equals(20.0));
    });
  });

  group('Edge Cases', () {
    test('Handle medication with no doses', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Unused Med'),
      );

      final history = await db.getDoseHistory(medId);
      final adherence = await calculateTestAdherence(db, medId);

      expect(history.length, equals(0));
      expect(adherence, equals(0.0));
    });

    test('Handle future scheduled doses', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Future Med'),
      );

      final tomorrow = DateTime.now().add(const Duration(days: 1));

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: tomorrow,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: tomorrow,
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(1));
    });

    test('Handle very old dose history', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Old Med'),
      );

      final longAgo = DateTime.now().subtract(const Duration(days: 365));

      await db.recordDoseTaken(
        medicationId: medId,
        scheduledDate: longAgo,
        scheduledHour: 8,
        scheduledMinute: 0,
        actualTime: longAgo,
      );

      final history = await db.getDoseHistory(medId);
      expect(history.length, equals(1));
      expect(history.first.scheduledDate.year, equals(longAgo.year));
    });

    test('Handle empty date range', () async {
      final today = DateTime.now();
      final stats = await db.getAdherenceStats(today, today);

      expect(stats, isNotNull);
      expect(stats['taken'] ?? 0, equals(0));
    });
  });
}
