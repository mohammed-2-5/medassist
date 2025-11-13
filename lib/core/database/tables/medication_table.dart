import 'package:drift/drift.dart';

/// Medications table - stores all medication information
class Medications extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Step 1: Type & Info
  TextColumn get medicineType => text()();
  TextColumn get medicineName => text()();
  TextColumn get medicinePhotoPath => text().nullable()();
  TextColumn get strength => text().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isScanned => boolean().withDefault(const Constant(false))();

  // Step 2: Schedule & Duration
  IntColumn get timesPerDay => integer().withDefault(const Constant(1))();
  RealColumn get dosePerTime => real().withDefault(const Constant(1))();
  TextColumn get doseUnit => text().withDefault(const Constant('tablet'))();
  IntColumn get durationDays => integer().withDefault(const Constant(7))();
  DateTimeColumn get startDate => dateTime()();

  // Repetition pattern
  TextColumn get repetitionPattern =>
      text().withDefault(const Constant('daily'))(); // daily, everyOtherDay, etc.
  TextColumn get specificDaysOfWeek =>
      text().withDefault(const Constant('1,2,3,4,5,6,7'))(); // Comma-separated weekday numbers

  // Step 3: Stock & Reminder
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  BoolColumn get remindBeforeRunOut =>
      boolean().withDefault(const Constant(true))();
  IntColumn get reminderDaysBeforeRunOut =>
      integer().withDefault(const Constant(3))();
  DateTimeColumn get expiryDate => dateTime().nullable()(); // Expiry date for stock
  IntColumn get reminderDaysBeforeExpiry =>
      integer().withDefault(const Constant(30))(); // Remind 30 days before expiry

  // Advanced Reminder Settings (Phase 2)
  TextColumn get customSoundPath => text().nullable()(); // Path to custom notification sound
  IntColumn get maxSnoozesPerDay =>
      integer().withDefault(const Constant(3))(); // Limit snoozes
  BoolColumn get enableRecurringReminders =>
      boolean().withDefault(const Constant(false))(); // For missed doses
  IntColumn get recurringReminderInterval =>
      integer().withDefault(const Constant(30))(); // Minutes between recurring reminders

  // Metadata
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

/// Reminder times table - stores reminder times for each medication
class ReminderTimes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  IntColumn get orderIndex => integer()(); // To maintain order

  // Advanced Reminder Options (Phase 2)
  TextColumn get mealTiming => text()
      .withDefault(const Constant('anytime'))(); // 'before_meal', 'with_meal', 'after_meal', 'anytime'
  IntColumn get mealOffsetMinutes => integer()
      .withDefault(const Constant(0))(); // Offset from meal time (e.g., 30 min before)

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE',
      ];
}
