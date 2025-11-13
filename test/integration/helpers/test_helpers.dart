import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:med_assist/core/database/app_database.dart';

/// Integration Test Helpers
/// Utilities for setting up and managing integration tests

/// Create a test database with in-memory storage
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Test Data Builders

/// Create a test medication with default values
MedicationsCompanion createTestMedication({
  String name = 'Test Medication',
  String medicineType = 'pill',
  String? strength = '500',
  String? unit = 'mg',
  int timesPerDay = 2,
  double dosePerTime = 1.0,
  int stockQuantity = 30,
  int reminderDaysBeforeRunOut = 7,
  DateTime? startDate,
  DateTime? expiryDate,
  String repetitionPattern = 'daily',
  bool isActive = true,
}) {
  return MedicationsCompanion.insert(
    medicineName: name,
    medicineType: medicineType,
    strength: Value(strength),
    unit: Value(unit),
    timesPerDay: Value(timesPerDay),
    dosePerTime: Value(dosePerTime),
    stockQuantity: Value(stockQuantity),
    reminderDaysBeforeRunOut: Value(reminderDaysBeforeRunOut),
    startDate: startDate ?? DateTime.now(),
    expiryDate: Value(expiryDate),
    repetitionPattern: Value(repetitionPattern),
    isActive: Value(isActive),
    createdAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  );
}

/// Create multiple test medications at once
Future<List<int>> createMultipleTestMedications(
  AppDatabase db,
  int count, {
  String namePrefix = 'Medication',
}) async {
  final ids = <int>[];
  for (var i = 1; i <= count; i++) {
    final id = await db.insertMedication(
      createTestMedication(name: '$namePrefix $i'),
    );
    ids.add(id);
  }
  return ids;
}

/// Create test reminder times
List<({int hour, int minute, String mealTiming, int mealOffsetMinutes})>
    createTestReminderTimes({
  int count = 2,
}) {
  final times = <({int hour, int minute, String mealTiming, int mealOffsetMinutes})>[];

  if (count >= 1) {
    times.add((hour: 8, minute: 0, mealTiming: 'anytime', mealOffsetMinutes: 0));
  }
  if (count >= 2) {
    times.add((hour: 20, minute: 0, mealTiming: 'anytime', mealOffsetMinutes: 0));
  }

  for (var i = 2; i < count; i++) {
    times.add((
      hour: 12 + (i - 2) * 4,
      minute: 0,
      mealTiming: 'anytime',
      mealOffsetMinutes: 0
    ));
  }

  return times;
}

/// Record test dose history
Future<void> recordTestDoseHistory(
  AppDatabase db, {
  required int medicationId,
  required String status,
  int daysAgo = 0,
  int hour = 8,
  int minute = 0,
}) async {
  final scheduledDate = DateTime.now().subtract(Duration(days: daysAgo));

  if (status == 'taken') {
    await db.recordDoseTaken(
      medicationId: medicationId,
      scheduledDate: scheduledDate,
      scheduledHour: hour,
      scheduledMinute: minute,
      actualTime: scheduledDate.add(const Duration(minutes: 5)),
    );
  } else if (status == 'skipped') {
    await db.recordDoseSkipped(
      medicationId: medicationId,
      scheduledDate: scheduledDate,
      scheduledHour: hour,
      scheduledMinute: minute,
    );
  } else if (status == 'snoozed') {
    await db.recordDoseSnoozed(
      medicationId: medicationId,
      scheduledDate: scheduledDate,
      scheduledHour: hour,
      scheduledMinute: minute,
    );
  }
}

/// Create a complete medication with reminders and dose history
Future<int> createCompleteTestMedication(
  AppDatabase db, {
  String name = 'Complete Test Med',
  int reminderTimesCount = 2,
  int doseHistoryDays = 7,
}) async {
  final medId = await db.insertMedication(
    createTestMedication(name: name),
  );

  final reminderTimes = createTestReminderTimes(count: reminderTimesCount);
  await db.insertReminderTimes(medId, reminderTimes);

  for (var day = 0; day < doseHistoryDays; day++) {
    for (final time in reminderTimes) {
      final status = (day + time.hour) % 3 == 0 ? 'skipped' : 'taken';
      await recordTestDoseHistory(
        db,
        medicationId: medId,
        status: status,
        daysAgo: day,
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  return medId;
}

/// Wait for async operations
Future<void> pumpAndSettle() async {
  await Future.delayed(const Duration(milliseconds: 100));
}

/// Clean up database after test
Future<void> cleanupDatabase(AppDatabase db) async {
  await db.close();
}

/// Build medication context string for AI tests
String buildMedicationContext(List<Medication> medications) {
  if (medications.isEmpty) {
    return 'No medications currently being taken.';
  }

  final buffer = StringBuffer('Current medications:\n');
  for (final med in medications) {
    buffer.writeln(
      '- ${med.medicineName}: ${med.strength ?? ""}${med.unit ?? ""}, '
      '${med.timesPerDay}x per day',
    );
  }

  return buffer.toString();
}

/// Verify two medications are equal
bool medicationsEqual(Medication a, Medication b) {
  return a.id == b.id &&
      a.medicineName == b.medicineName &&
      a.medicineType == b.medicineType &&
      a.strength == b.strength &&
      a.unit == b.unit &&
      a.timesPerDay == b.timesPerDay;
}

/// Count total doses in dose history
Future<int> countTotalDoses(AppDatabase db, int medicationId) async {
  final history = await db.getDoseHistory(medicationId);
  return history.length;
}

/// Calculate adherence percentage from dose history
Future<double> calculateTestAdherence(AppDatabase db, int medicationId) async {
  final history = await db.getDoseHistory(medicationId);
  if (history.isEmpty) return 0.0;

  final takenCount = history.where((d) => d.status == 'taken').length;
  return (takenCount / history.length) * 100.0;
}
