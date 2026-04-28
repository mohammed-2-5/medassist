import 'package:drift/drift.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';

/// Persists drug-interaction warnings the user accepted (e.g. by tapping
/// "Add Anyway") so that both medications carry the warning thereafter.
///
/// Backed by the `medication_interactions` raw-SQL table. Rows are
/// auto-removed when either medication is hard-deleted (FK cascade) and
/// filtered out when either side is soft-deleted (isActive = 0).
class PersistedInteractionService {
  PersistedInteractionService(this._db);

  final AppDatabase _db;

  /// Persist a list of warnings linked to [newMedicationId]. Warnings without
  /// a known second medication id are skipped (they have nothing to link to).
  Future<void> persistAccepted({
    required int newMedicationId,
    required List<InteractionWarning> warnings,
  }) async {
    // Last-chance fuzzy match for AI warnings whose drug2 name didn't match an
    // existing medicineName at check-time (e.g. AI says "Paracetamol" but the
    // user saved brand "Panadol"). Look at active meds *now* and try matching
    // by ingredients/generic/brand substrings on either side of the pair.
    final activeMeds = await _db.getAllMedications();
    int? resolveId(InteractionWarning w) {
      if (w.medication2Id != null && w.medication2Id != newMedicationId) {
        return w.medication2Id;
      }
      if (w.medication1Id != null && w.medication1Id != newMedicationId) {
        return w.medication1Id;
      }
      return _fuzzyMatch(w.medication2, activeMeds, exclude: newMedicationId) ??
          _fuzzyMatch(w.medication1, activeMeds, exclude: newMedicationId);
    }

    for (final w in warnings) {
      final otherId = resolveId(w);
      if (otherId == null || otherId == newMedicationId) continue;

      final pair = _orderedPair(newMedicationId, otherId);

      await _db.customStatement(
        'INSERT OR REPLACE INTO medication_interactions ('
        'medication1_id, medication2_id, severity, '
        'description_en, description_ar, '
        'recommendation_en, recommendation_ar, evidence, accepted_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          pair.$1,
          pair.$2,
          w.severity.name,
          w.description,
          w.descriptionAr,
          w.recommendation,
          w.recommendationAr,
          w.evidence,
          DateTime.now().millisecondsSinceEpoch,
        ],
      );
    }
  }

  /// All persisted warnings touching [medicationId] where the OTHER
  /// medication is still active.
  Future<List<InteractionWarning>> forMedication(int medicationId) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT mi.*, m1.medicine_name AS m1_name, m2.medicine_name AS m2_name
      FROM medication_interactions mi
      INNER JOIN medications m1 ON m1.id = mi.medication1_id
      INNER JOIN medications m2 ON m2.id = mi.medication2_id
      WHERE (mi.medication1_id = ? OR mi.medication2_id = ?)
        AND m1.is_active = 1 AND m2.is_active = 1
      ORDER BY mi.accepted_at DESC
      ''',
          variables: [
            Variable.withInt(medicationId),
            Variable.withInt(medicationId),
          ],
        )
        .get();

    return rows.map(_rowToWarning).toList();
  }

  /// Remove every interaction record involving this medication. Used by the
  /// soft-delete path so warnings disappear from the other med's screen.
  Future<void> removeForMedication(int medicationId) async {
    await _db.customStatement(
      'DELETE FROM medication_interactions '
      'WHERE medication1_id = ? OR medication2_id = ?',
      [medicationId, medicationId],
    );
  }

  InteractionWarning _rowToWarning(QueryRow row) {
    return InteractionWarning(
      medication1: row.read<String>('m1_name'),
      medication2: row.read<String>('m2_name'),
      severity: _parseSeverity(row.read<String>('severity')),
      description: row.readNullable<String>('description_en') ?? '',
      recommendation: row.readNullable<String>('recommendation_en') ?? '',
      descriptionAr: row.readNullable<String>('description_ar'),
      recommendationAr: row.readNullable<String>('recommendation_ar'),
      evidence: row.readNullable<String>('evidence'),
      medication1Id: row.read<int>('medication1_id'),
      medication2Id: row.read<int>('medication2_id'),
    );
  }

  (int, int) _orderedPair(int a, int b) => a < b ? (a, b) : (b, a);

  int? _fuzzyMatch(String name, List<Medication> meds, {required int exclude}) {
    final target = name.toLowerCase().trim();
    if (target.isEmpty) return null;
    for (final m in meds) {
      if (m.id == exclude) continue;
      final brand = m.medicineName.toLowerCase().trim();
      final generic = (m.genericName ?? '').toLowerCase().trim();
      final ingredients = (m.activeIngredients ?? '').toLowerCase();
      if (brand == target) return m.id;
      if (generic.isNotEmpty &&
          (generic == target ||
              generic.contains(target) ||
              target.contains(generic))) {
        return m.id;
      }
      if (ingredients.isNotEmpty && ingredients.contains(target)) return m.id;
      if (brand.contains(target) || target.contains(brand)) return m.id;
    }
    return null;
  }

  InteractionSeverity _parseSeverity(String value) {
    return InteractionSeverity.values.firstWhere(
      (s) => s.name == value,
      orElse: () => InteractionSeverity.moderate,
    );
  }
}
