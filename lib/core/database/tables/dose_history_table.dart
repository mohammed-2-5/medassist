import 'package:drift/drift.dart';
import 'package:med_assist/core/database/tables/medication_table.dart';

/// Dose history table - tracks when doses are taken/skipped/snoozed
class DoseHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();

  // Scheduled information
  DateTimeColumn get scheduledDate => dateTime()();
  IntColumn get scheduledHour => integer()();
  IntColumn get scheduledMinute => integer()();

  // Actual information
  TextColumn get status =>
      text()(); // 'taken', 'skipped', 'snoozed', 'missed'
  DateTimeColumn get actualTime =>
      dateTime().nullable()(); // When actually taken
  TextColumn get notes => text().nullable()(); // Optional notes

  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE',
      ];
}
