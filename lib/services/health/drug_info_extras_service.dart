import 'package:drift/drift.dart';
import 'package:med_assist/core/database/app_database.dart';

/// Persists extra AI-derived drug-info fields not modelled in the Drift
/// `medication_drug_info` table: alcoholWarning, contraindications,
/// requiresMonitoring, otcOrPrescription.
class DrugInfoExtrasService {
  DrugInfoExtrasService(this._db);

  final AppDatabase _db;

  Future<void> upsert({
    required int medicationId,
    required String language,
    String? alcoholWarning,
    String? contraindications,
    String? requiresMonitoring,
    String? otcOrPrescription,
  }) async {
    await _db.customStatement(
      'INSERT OR REPLACE INTO medication_drug_info_extras ('
      'medication_id, language, alcohol_warning, contraindications, '
      'requires_monitoring, otc_or_prescription, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        medicationId,
        language,
        alcoholWarning,
        contraindications,
        requiresMonitoring,
        otcOrPrescription,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  /// Returns one row per language for the given medication.
  Future<List<DrugInfoExtras>> forMedication(int medicationId) async {
    final rows = await _db.customSelect(
      'SELECT * FROM medication_drug_info_extras WHERE medication_id = ?',
      variables: [Variable.withInt(medicationId)],
    ).get();
    return rows
        .map(
          (r) => DrugInfoExtras(
            language: r.read<String>('language'),
            alcoholWarning: r.readNullable<String>('alcohol_warning'),
            contraindications: r.readNullable<String>('contraindications'),
            requiresMonitoring: r.readNullable<String>('requires_monitoring'),
            otcOrPrescription: r.readNullable<String>('otc_or_prescription'),
          ),
        )
        .toList();
  }
}

class DrugInfoExtras {
  const DrugInfoExtras({
    required this.language,
    this.alcoholWarning,
    this.contraindications,
    this.requiresMonitoring,
    this.otcOrPrescription,
  });

  final String language;
  final String? alcoholWarning;
  final String? contraindications;
  final String? requiresMonitoring;
  final String? otcOrPrescription;
}
