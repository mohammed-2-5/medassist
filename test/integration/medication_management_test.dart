import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/core/database/app_database.dart';

import 'helpers/test_helpers.dart';

/// Integration Tests for Medication Management Flow
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

  group('Medication Creation Flow', () {
    test('User can add a new medication with basic details', () async {
      final medication = createTestMedication(
        name: 'Aspirin',
      );

      final medId = await db.insertMedication(medication);

      expect(medId, greaterThan(0));

      final savedMed = await db.getMedicationById(medId);
      expect(savedMed, isNotNull);
      expect(savedMed!.medicineName, equals('Aspirin'));
      expect(savedMed.strength, equals('500'));
      expect(savedMed.unit, equals('mg'));
      expect(savedMed.timesPerDay, equals(2));
      expect(savedMed.isActive, isTrue);
    });

    test('User can add medication with reminder times', () async {
      final medication = createTestMedication(name: 'Lisinopril');
      final reminderTimes = createTestReminderTimes();

      final medId = await db.insertMedication(medication);
      await db.insertReminderTimes(medId, reminderTimes);

      final times = await db.getReminderTimes(medId);
      expect(times.length, equals(2));
      expect(times[0].hour, equals(8));
      expect(times[0].minute, equals(0));
      expect(times[1].hour, equals(20));
      expect(times[1].minute, equals(0));
    });

    test('User can add multiple medications', () async {
      final ids = await createMultipleTestMedications(db, 3);

      expect(ids.length, equals(3));

      final allMeds = await db.getAllMedications();
      expect(allMeds.length, equals(3));
    });

    test('Medication is created with correct default values', () async {
      final medication = createTestMedication(name: 'Metformin');

      final medId = await db.insertMedication(medication);
      final savedMed = await db.getMedicationById(medId);

      expect(savedMed!.isActive, isTrue);
      expect(savedMed.stockQuantity, equals(30));
      expect(savedMed.reminderDaysBeforeRunOut, equals(7));
      expect(savedMed.repetitionPattern, equals('daily'));
      expect(savedMed.createdAt, isNotNull);
      expect(savedMed.updatedAt, isNotNull);
    });
  });

  group('Medication Retrieval Flow', () {
    test('User can view all active medications', () async {
      await createMultipleTestMedications(db, 5);

      final meds = await db.getAllMedications();

      expect(meds.length, equals(5));
      for (final med in meds) {
        expect(med.isActive, isTrue);
      }
    });

    test('User can retrieve specific medication by ID', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Atorvastatin'),
      );

      final med = await db.getMedicationById(medId);

      expect(med, isNotNull);
      expect(med!.id, equals(medId));
      expect(med.medicineName, equals('Atorvastatin'));
    });

    test('User can search for medications by name', () async {
      await db.insertMedication(createTestMedication(name: 'Aspirin'));
      await db.insertMedication(createTestMedication(name: 'Ibuprofen'));
      await db.insertMedication(createTestMedication(name: 'Acetaminophen'));

      final results = await db.searchMedications('rin');

      expect(results.length, equals(1));
      expect(results.first.medicineName, equals('Aspirin'));
    });

    test('User can get medications with reminder times', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Lisinopril'),
      );
      await db.insertReminderTimes(medId, createTestReminderTimes(count: 3));

      final medsWithReminders = await db.getMedicationsWithReminders();

      expect(medsWithReminders.length, equals(1));
      expect(medsWithReminders.first.medication.medicineName, equals('Lisinopril'));
      expect(medsWithReminders.first.reminderTimes.length, equals(3));
    });

    test("Inactive medications don't appear in default list", () async {
      await db.insertMedication(
        createTestMedication(name: 'Active Med'),
      );
      await db.insertMedication(
        createTestMedication(name: 'Inactive Med', isActive: false),
      );

      final activeMeds = await db.getAllMedications();
      final allMeds = await db.getAllMedicationsIncludingInactive();

      expect(activeMeds.length, equals(1));
      expect(activeMeds.first.medicineName, equals('Active Med'));

      expect(allMeds.length, equals(2));
    });
  });

  group('Medication Update Flow', () {
    test('User can update medication details', () async {
      final medId = await db.insertMedication(
        createTestMedication(
          name: 'Original Name',
        ),
      );

      final originalMed = await db.getMedicationById(medId);
      final updatedMed = originalMed!.copyWith(
        medicineName: 'Updated Name',
        strength: const Value('1000'),
        updatedAt: DateTime.now(),
      );
      final updateSuccess = await db.updateMedication(updatedMed);

      expect(updateSuccess, isTrue);

      final savedMed = await db.getMedicationById(medId);
      expect(savedMed!.medicineName, equals('Updated Name'));
      expect(savedMed.strength, equals('1000'));
    });

    test('User can update reminder times', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Test Med'),
      );
      await db.insertReminderTimes(medId, createTestReminderTimes());

      final newTimes = [
        (hour: 9, minute: 0, mealTiming: 'before_meal', mealOffsetMinutes: 30),
        (hour: 15, minute: 0, mealTiming: 'after_meal', mealOffsetMinutes: 15),
        (hour: 21, minute: 0, mealTiming: 'anytime', mealOffsetMinutes: 0),
      ];
      await db.updateReminderTimes(medId, newTimes);

      final times = await db.getReminderTimes(medId);
      expect(times.length, equals(3));
      expect(times[0].hour, equals(9));
      expect(times[0].mealTiming, equals('before_meal'));
      expect(times[1].hour, equals(15));
      expect(times[2].hour, equals(21));
    });

    test('User can update stock quantity', () async {
      final medId = await db.insertMedication(
        createTestMedication(),
      );

      final med = await db.getMedicationById(medId);
      final updated = med!.copyWith(
        stockQuantity: 60,
        updatedAt: DateTime.now(),
      );
      await db.updateMedication(updated);

      final savedMed = await db.getMedicationById(medId);
      expect(savedMed!.stockQuantity, equals(60));
    });
  });

  group('Medication Deletion Flow', () {
    test('User can soft delete medication', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'To Be Deleted'),
      );

      final deleteCount = await db.deleteMedication(medId);

      expect(deleteCount, equals(1));

      final med = await db.getMedicationById(medId);
      expect(med, isNotNull);
      expect(med!.isActive, isFalse);

      final activeMeds = await db.getAllMedications();
      expect(activeMeds.any((m) => m.id == medId), isFalse);
    });

    test('User can hard delete medication', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'To Be Hard Deleted'),
      );

      final deleteCount = await db.hardDeleteMedication(medId);

      expect(deleteCount, equals(1));

      final med = await db.getMedicationById(medId);
      expect(med, isNull);
    });
  });

  group('Medication Edge Cases', () {
    test('Handles medication with zero stock', () async {
      final medId = await db.insertMedication(
        createTestMedication(stockQuantity: 0),
      );

      final med = await db.getMedicationById(medId);
      expect(med!.stockQuantity, equals(0));
    });

    test('Handles medication with very long name', () async {
      final longName = 'A' * 200;

      final medId = await db.insertMedication(
        createTestMedication(name: longName),
      );

      final med = await db.getMedicationById(medId);
      expect(med!.medicineName, equals(longName));
    });

    test('Handles medication with special characters in name', () async {
      const specialName = 'Med-Name (500mg) [2x/day]';

      final medId = await db.insertMedication(
        createTestMedication(name: specialName),
      );

      final med = await db.getMedicationById(medId);
      expect(med!.medicineName, equals(specialName));
    });
  });

  group('Medication Complex Scenarios', () {
    test('Complete medication management workflow', () async {
      final medId = await db.insertMedication(
        createTestMedication(name: 'Lisinopril', strength: '10'),
      );
      await db.insertReminderTimes(medId, createTestReminderTimes());

      var med = await db.getMedicationById(medId);
      expect(med!.medicineName, equals('Lisinopril'));

      med = med.copyWith(strength: const Value('20'), updatedAt: DateTime.now());
      await db.updateMedication(med);

      med = await db.getMedicationById(medId);
      expect(med.strength, equals('20'));

      await db.deleteMedication(medId);

      final activeMeds = await db.getAllMedications();
      expect(activeMeds.any((m) => m.id == medId), isFalse);

      final allMeds = await db.getAllMedicationsIncludingInactive();
      expect(allMeds.any((m) => m.id == medId), isTrue);
    });

    test('Multiple medications with different configurations', () async {
      await db.insertMedication(createTestMedication(
        name: 'Med 1',
        timesPerDay: 1,
      ));
      await db.insertMedication(createTestMedication(
        name: 'Med 2',
      ));
      await db.insertMedication(createTestMedication(
        name: 'Med 3',
        timesPerDay: 3,
      ));

      final meds = await db.getAllMedications();
      expect(meds.length, equals(3));
      expect(meds[0].timesPerDay, isIn([1, 2, 3]));
      expect(meds[1].timesPerDay, isIn([1, 2, 3]));
      expect(meds[2].timesPerDay, isIn([1, 2, 3]));
    });
  });
}
