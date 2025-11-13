import 'package:drift/drift.dart';
import 'package:med_assist/core/database/tables/medication_table.dart';

/// Stock History table - logs all stock changes for audit trail
class StockHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();

  // Stock change details
  IntColumn get previousStock => integer()();
  IntColumn get newStock => integer()();
  IntColumn get changeAmount => integer()(); // Can be negative for usage
  TextColumn get changeType =>
      text()(); // 'restock', 'usage', 'adjustment', 'expired'

  // Optional details
  TextColumn get notes => text().nullable()();
  DateTimeColumn get changeDate =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE',
      ];
}
