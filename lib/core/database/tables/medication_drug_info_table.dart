import 'package:drift/drift.dart';
import 'package:med_assist/core/database/tables/medication_table.dart';

/// Bilingual AI-enriched drug info per medication (Issue 5 — v12).
/// One row per (medicationId, language). Language: 'en' | 'ar'.
class MedicationDrugInfo extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  TextColumn get language => text()(); // 'en' | 'ar'

  TextColumn get howToTake => text().nullable()(); // before/after meal + water
  TextColumn get bestTimeOfDay => text().nullable()();
  BoolColumn get drowsinessAffectsDriving =>
      boolean().withDefault(const Constant(false))();
  TextColumn get drowsinessWarning => text().nullable()(); // optional note
  TextColumn get foodsToAvoid => text().nullable()();
  TextColumn get missedDoseAdvice => text().nullable()();
  TextColumn get storageInstructions => text().nullable()();

  TextColumn get genericName => text().nullable()();
  TextColumn get purpose => text().nullable()();
  TextColumn get sideEffects => text().nullable()();
  TextColumn get warnings => text().nullable()();
  TextColumn get drugCategory => text().nullable()();
  TextColumn get activeIngredients => text().nullable()();
  TextColumn get route => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE',
    'UNIQUE (medication_id, language)',
  ];
}
