import 'package:drift/drift.dart';

/// Snooze history table for tracking daily snooze counts
@DataClassName('SnoozeHistoryData')
class SnoozeHistoryTable extends Table {
  @override
  String get tableName => 'snooze_history';

  /// Auto-incrementing primary key
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to medications table
  IntColumn get medicationId => integer()();

  /// Date for this snooze record (date only, no time)
  DateTimeColumn get snoozeDate => dateTime()();

  /// Number of times snoozed today
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();

  /// Last snooze timestamp
  DateTimeColumn get lastSnoozeTime => dateTime()();

  /// Suggested snooze minutes used
  IntColumn get suggestedMinutes => integer().withDefault(const Constant(15))();
}
