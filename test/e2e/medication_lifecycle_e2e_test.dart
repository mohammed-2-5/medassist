import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/core/database/app_database.dart';

/// End-to-End Tests for Complete Medication Lifecycle
/// Tests complete user journeys from start to finish

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    final meds = await db.getAllMedicationsIncludingInactive();
    for (final med in meds) {
      await db.hardDeleteMedication(med.id);
    }
    await db.close();
  });

  group('Complete Medication Lifecycle E2E', () {
    test(
      'User Journey: Add medication → Take doses → View analytics → Manage stock',
      () async {
        // Step 1: Add a new medication
        print('\n📋 Step 1: Adding new medication...');
        final medId = await db.insertMedication(
          MedicationsCompanion.insert(
            medicineName: 'Aspirin',
            medicineType: 'pill',
            strength: const Value('500'),
            unit: const Value('mg'),
            timesPerDay: const Value(2),
            dosePerTime: const Value(1),
            stockQuantity: const Value(30),
            reminderDaysBeforeRunOut: const Value(7),
            startDate: DateTime.now(),
            repetitionPattern: const Value('daily'),
            isActive: const Value(true),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );

        expect(medId, greaterThan(0));
        print('✅ Medication added with ID: $medId');

        // Step 2: Add reminder times
        print('\n⏰ Step 2: Setting up reminder times...');
        await db.insertReminderTimes(medId, [
          (
            hour: 8,
            minute: 0,
            mealTiming: 'before_meal',
            mealOffsetMinutes: 30,
          ),
          (
            hour: 20,
            minute: 0,
            mealTiming: 'after_meal',
            mealOffsetMinutes: 60,
          ),
        ]);

        final times = await db.getReminderTimes(medId);
        expect(times.length, equals(2));
        print('✅ Reminder times set: ${times.length} reminders');

        // Step 3: Verify medication was added correctly
        print('\n🔍 Step 3: Verifying medication details...');
        final med = await db.getMedicationById(medId);
        expect(med, isNotNull);
        expect(med!.medicineName, equals('Aspirin'));
        expect(med.strength, equals('500'));
        expect(med.unit, equals('mg'));
        expect(med.stockQuantity, equals(30));
        print('✅ Medication details verified');

        // Step 4: Simulate taking doses over a week
        print('\n💊 Step 4: Taking doses over a week...');
        final today = DateTime.now();
        var takenCount = 0;
        var skippedCount = 0;

        for (var day = 0; day < 7; day++) {
          final date = today.subtract(Duration(days: day));

          // Morning dose - mostly taken
          if (day % 4 != 0) {
            await db.recordDoseTaken(
              medicationId: medId,
              scheduledDate: date,
              scheduledHour: 8,
              scheduledMinute: 0,
              actualTime: date.add(const Duration(hours: 8, minutes: 5)),
            );
            takenCount++;
          } else {
            await db.recordDoseSkipped(
              medicationId: medId,
              scheduledDate: date,
              scheduledHour: 8,
              scheduledMinute: 0,
              notes: 'Forgot to take',
            );
            skippedCount++;
          }

          // Evening dose - always taken
          await db.recordDoseTaken(
            medicationId: medId,
            scheduledDate: date,
            scheduledHour: 20,
            scheduledMinute: 0,
            actualTime: date.add(const Duration(hours: 20)),
          );
          takenCount++;
        }

        print('✅ Doses recorded: $takenCount taken, $skippedCount skipped');

        // Step 5: Verify dose history
        print('\n📊 Step 5: Checking dose history...');
        final history = await db.getDoseHistory(medId);
        expect(history.length, equals(14)); // 7 days × 2 doses/day

        final takenDoses = history.where((d) => d.status == 'taken').length;
        final skippedDoses = history.where((d) => d.status == 'skipped').length;

        expect(takenDoses, equals(takenCount));
        expect(skippedDoses, equals(skippedCount));
        print(
          '✅ Dose history verified: $takenDoses taken, $skippedDoses skipped',
        );

        // Step 6: Calculate adherence
        print('\n📈 Step 6: Calculating adherence...');
        final adherencePercentage =
            (takenCount / (takenCount + skippedCount)) * 100;
        expect(adherencePercentage, greaterThan(70)); // Should be >70%
        print('✅ Adherence: ${adherencePercentage.toStringAsFixed(1)}%');

        // Step 7: Get adherence stats for date range
        print('\n📉 Step 7: Getting adherence statistics...');
        final weekAgo = today.subtract(const Duration(days: 7));
        final stats = await db.getAdherenceStats(weekAgo, today);

        expect(stats['taken'], equals(takenCount));
        expect(stats['skipped'], equals(skippedCount));
        print(
          '✅ Stats retrieved: ${stats['taken']} taken, ${stats['skipped']} skipped',
        );

        // Step 8: Check stock levels
        print('\n📦 Step 8: Checking stock levels...');
        final currentMed = await db.getMedicationById(medId);
        expect(
          currentMed!.stockQuantity,
          equals(30),
        ); // Stock not auto-decremented
        print('✅ Stock level: ${currentMed.stockQuantity} remaining');

        // Step 9: Manually update stock (simulate refill)
        print('\n🔄 Step 9: Refilling medication stock...');
        await db.updateMedicationStock(medId, 60);
        await db.logStockChange(
          medicationId: medId,
          previousStock: 30,
          newStock: 60,
          changeType: 'addition',
          notes: 'Monthly refill',
        );

        final refilled = await db.getMedicationById(medId);
        expect(refilled!.stockQuantity, equals(60));
        print('✅ Stock refilled: ${refilled.stockQuantity} pills');

        // Step 10: Check for low stock alerts
        print('\n⚠️  Step 10: Checking low stock alerts...');
        final lowStockMeds = await db.getLowStockMedications();
        expect(
          lowStockMeds.any((m) => m.id == medId),
          isFalse,
        ); // Should not be low
        print('✅ Stock level is adequate (no alerts)');

        // Step 11: Update medication details
        print('\n✏️  Step 11: Updating medication details...');
        final updated = refilled.copyWith(
          strength: const Value('1000'),
          updatedAt: DateTime.now(),
        );
        await db.updateMedication(updated);

        final modified = await db.getMedicationById(medId);
        expect(modified!.strength, equals('1000'));
        print('✅ Medication updated: strength changed to 1000mg');

        // Step 12: Search for medication
        print('\n🔍 Step 12: Searching for medication...');
        final searchResults = await db.searchMedications('Asp');
        expect(searchResults.length, equals(1));
        expect(searchResults.first.medicineName, equals('Aspirin'));
        print('✅ Search working: found "${searchResults.first.medicineName}"');

        // Step 13: Soft delete medication
        print('\n🗑️  Step 13: Soft deleting medication...');
        await db.deleteMedication(medId);

        final softDeleted = await db.getMedicationById(medId);
        expect(softDeleted, isNotNull);
        expect(softDeleted!.isActive, isFalse);
        print('✅ Medication soft deleted (inactive)');

        // Step 14: Verify it doesn't appear in active list
        print('\n📋 Step 14: Verifying active medications list...');
        final activeMeds = await db.getAllMedications();
        expect(activeMeds.any((m) => m.id == medId), isFalse);

        final allMeds = await db.getAllMedicationsIncludingInactive();
        expect(allMeds.any((m) => m.id == medId), isTrue);
        print('✅ Medication removed from active list');

        // Final Summary
        print('\n${'=' * 50}');
        print('✅ COMPLETE MEDICATION LIFECYCLE TEST PASSED');
        print('=' * 50);
        print('• Medication added and configured');
        print('• Doses tracked over 7 days');
        print(
          '• Adherence calculated: ${adherencePercentage.toStringAsFixed(1)}%',
        );
        print('• Stock managed and refilled');
        print('• Medication updated and deleted');
        print('• All data properly persisted');
        print('=' * 50 + '\n');
      },
    );

    test('User Journey: Multi-medication management with analytics', () async {
      print('\n📋 Multi-Medication Management Journey');

      // Add multiple medications
      print('\n1️⃣ Adding multiple medications...');
      final med1 = await db.insertMedication(
        MedicationsCompanion.insert(
          medicineName: 'Lisinopril',
          medicineType: 'pill',
          strength: const Value('10'),
          unit: const Value('mg'),
          timesPerDay: const Value(1),
          stockQuantity: const Value(30),
          startDate: DateTime.now(),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final med2 = await db.insertMedication(
        MedicationsCompanion.insert(
          medicineName: 'Metformin',
          medicineType: 'pill',
          strength: const Value('500'),
          unit: const Value('mg'),
          timesPerDay: const Value(2),
          stockQuantity: const Value(60),
          startDate: DateTime.now(),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final med3 = await db.insertMedication(
        MedicationsCompanion.insert(
          medicineName: 'Vitamin D',
          medicineType: 'capsule',
          strength: const Value('1000'),
          unit: const Value('IU'),
          timesPerDay: const Value(1),
          stockQuantity: const Value(90),
          startDate: DateTime.now(),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      print('✅ Added 3 medications');

      // Record doses for each
      print('\n2️⃣ Recording doses...');
      final today = DateTime.now();

      // Lisinopril - perfect adherence
      for (var i = 0; i < 7; i++) {
        await db.recordDoseTaken(
          medicationId: med1,
          scheduledDate: today.subtract(Duration(days: i)),
          scheduledHour: 8,
          scheduledMinute: 0,
          actualTime: today
              .subtract(Duration(days: i))
              .add(const Duration(hours: 8)),
        );
      }

      // Metformin - partial adherence
      for (var i = 0; i < 7; i++) {
        if (i % 2 == 0) {
          await db.recordDoseTaken(
            medicationId: med2,
            scheduledDate: today.subtract(Duration(days: i)),
            scheduledHour: 8,
            scheduledMinute: 0,
            actualTime: today
                .subtract(Duration(days: i))
                .add(const Duration(hours: 8)),
          );
        } else {
          await db.recordDoseSkipped(
            medicationId: med2,
            scheduledDate: today.subtract(Duration(days: i)),
            scheduledHour: 8,
            scheduledMinute: 0,
          );
        }
      }

      // Vitamin D - good adherence
      for (var i = 0; i < 6; i++) {
        await db.recordDoseTaken(
          medicationId: med3,
          scheduledDate: today.subtract(Duration(days: i)),
          scheduledHour: 8,
          scheduledMinute: 0,
          actualTime: today
              .subtract(Duration(days: i))
              .add(const Duration(hours: 8)),
        );
      }

      print('✅ Doses recorded for all medications');

      // Get analytics for each medication
      print('\n3️⃣ Calculating adherence for each medication...');
      final meds = await db.getAllMedications();
      expect(meds.length, equals(3));

      for (final med in meds) {
        final history = await db.getDoseHistory(med.id);
        final taken = history.where((d) => d.status == 'taken').length;
        final total = history.length;
        final adherence = total > 0 ? (taken / total * 100) : 0.0;

        print(
          '  • ${med.medicineName}: ${adherence.toStringAsFixed(1)}% adherence ($taken/$total)',
        );
      }

      // Get overall stats
      print('\n4️⃣ Overall statistics...');
      final weekAgo = today.subtract(const Duration(days: 7));
      final overallStats = await db.getAdherenceStats(weekAgo, today);

      final totalTaken = overallStats['taken'] ?? 0;
      final totalSkipped = overallStats['skipped'] ?? 0;
      final totalDoses = totalTaken + totalSkipped;
      final overallAdherence = totalDoses > 0
          ? (totalTaken / totalDoses * 100)
          : 0.0;

      print('  • Total doses: $totalDoses');
      print('  • Taken: $totalTaken');
      print('  • Skipped: $totalSkipped');
      print('  • Overall adherence: ${overallAdherence.toStringAsFixed(1)}%');

      expect(overallAdherence, greaterThan(60));

      print('\n✅ Multi-medication management complete\n');
    });

    test('User Journey: Stock management with expiry tracking', () async {
      print('\n📦 Stock Management & Expiry Journey');

      // Add medication with expiry date
      print('\n1️⃣ Adding medication with expiry date...');
      final today = DateTime.now();
      final expiryDate = today.add(const Duration(days: 20));

      final medId = await db.insertMedication(
        MedicationsCompanion.insert(
          medicineName: 'Temporary Med',
          medicineType: 'pill',
          stockQuantity: const Value(10),
          reminderDaysBeforeRunOut: const Value(7),
          expiryDate: Value(expiryDate),
          startDate: today,
          createdAt: Value(today),
          updatedAt: Value(today),
        ),
      );

      print(
        '✅ Medication added with expiry: ${expiryDate.toString().split(' ')[0]}',
      );

      // Check expiring medications
      print('\n2️⃣ Checking expiring medications...');
      final expiringMeds = await db.getExpiringMedications();
      expect(expiringMeds.any((m) => m.id == medId), isTrue);
      print('✅ Medication flagged as expiring soon');

      // Log stock changes
      print('\n3️⃣ Logging stock changes...');
      await db.logStockChange(
        medicationId: medId,
        previousStock: 10,
        newStock: 5,
        changeType: 'deduction',
        notes: 'Used 5 doses',
      );

      await db.updateMedicationStock(medId, 5);

      final stockHistory = await db.getStockHistory(medId);
      expect(stockHistory.length, equals(1));
      print('✅ Stock change logged');

      // Check low stock
      print('\n4️⃣ Checking low stock alerts...');
      final lowStock = await db.getLowStockMedications();
      // May or may not be low stock depending on usage rate
      print('  • Low stock medications: ${lowStock.length}');

      print('\n✅ Stock and expiry management complete\n');
    });
  });
}
