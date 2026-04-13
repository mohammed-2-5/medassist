import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/services/ai/ai_drug_info_service.dart';

class InteractionWarning {
  InteractionWarning({
    required this.medication1,
    required this.medication2,
    required this.severity,
    required this.description,
    required this.recommendation,
  });

  final String medication1;
  final String medication2;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;

  @override
  String toString() => '$medication1 + $medication2: $description';
}

enum InteractionSeverity {
  minor,
  moderate,
  major,
  severe,
}

class DrugInteractionService {
  DrugInteractionService(this._database);

  final AppDatabase _database;

  static const Map<String, List<String>> _categoryConflicts = {
    'nsaid': ['nsaid', 'anticoagulant', 'blood thinner'],
    'anticoagulant': ['nsaid', 'anticoagulant', 'antiplatelet'],
    'blood thinner': ['nsaid', 'blood thinner', 'anticoagulant'],
    'antiplatelet': ['anticoagulant', 'antiplatelet'],
    'ace inhibitor': ['arb', 'potassium-sparing diuretic'],
    'arb': ['ace inhibitor'],
    'ssri': ['maoi', 'snri', 'tca'],
    'maoi': ['ssri', 'snri', 'tca'],
    'snri': ['maoi', 'ssri'],
    'tca': ['maoi', 'ssri'],
  };

  static const Map<String, List<String>> _ingredientConflicts = {
    'warfarin': ['aspirin', 'ibuprofen', 'naproxen', 'diclofenac'],
    'aspirin': ['warfarin', 'ibuprofen', 'naproxen', 'heparin'],
    'ibuprofen': ['warfarin', 'aspirin', 'lithium', 'methotrexate'],
    'naproxen': ['warfarin', 'aspirin', 'lithium'],
    'diclofenac': ['warfarin', 'methotrexate'],
    'metformin': ['contrast dye'],
    'lisinopril': ['potassium', 'lithium'],
    'losartan': ['potassium', 'lithium'],
    'atorvastatin': ['clarithromycin', 'itraconazole'],
    'simvastatin': ['amlodipine', 'clarithromycin'],
    'ciprofloxacin': ['theophylline', 'warfarin'],
    'clarithromycin': ['simvastatin', 'atorvastatin', 'warfarin'],
    'sertraline': ['tramadol', 'warfarin'],
    'fluoxetine': ['tramadol', 'warfarin'],
    'tramadol': ['sertraline', 'fluoxetine', 'citalopram'],
    'digoxin': ['amiodarone', 'verapamil'],
    'lithium': ['ibuprofen', 'naproxen', 'lisinopril'],
    'levothyroxine': ['calcium', 'iron'],
    'amoxicillin': ['methotrexate'],
    'methotrexate': ['ibuprofen', 'diclofenac', 'amoxicillin'],
  };

  static const Map<String, InteractionSeverity> _knownSeverities = {
    'warfarin:aspirin': InteractionSeverity.severe,
    'warfarin:ibuprofen': InteractionSeverity.major,
    'warfarin:naproxen': InteractionSeverity.major,
    'tramadol:sertraline': InteractionSeverity.major,
    'tramadol:fluoxetine': InteractionSeverity.major,
    'simvastatin:amlodipine': InteractionSeverity.major,
    'atorvastatin:clarithromycin': InteractionSeverity.major,
    'lisinopril:potassium': InteractionSeverity.major,
    'levothyroxine:calcium': InteractionSeverity.moderate,
    'aspirin:ibuprofen': InteractionSeverity.moderate,
  };

  Future<List<InteractionWarning>> checkAllInteractions() async {
    final medications = await _database.getAllMedications();
    return _checkLocalInteractions(medications);
  }

  Future<List<InteractionWarning>> checkNewMedication(
    String medicationName, {
    String? activeIngredients,
    String? drugCategory,
  }) async {
    final existing = await _database.getAllMedications();
    final warnings = <InteractionWarning>[];

    final newIngredients = _parseIngredients(activeIngredients);
    final newCategory = drugCategory?.toLowerCase().trim() ?? '';

    for (final med in existing) {
      final existingIngredients = _parseIngredients(med.activeIngredients);
      final existingCategory = med.drugCategory?.toLowerCase().trim() ?? '';

      final categoryWarning = _checkCategoryConflict(
        medicationName,
        med.medicineName,
        newCategory,
        existingCategory,
      );
      if (categoryWarning != null) {
        warnings.add(categoryWarning);
        continue;
      }

      final ingredientWarning = _checkIngredientConflict(
        medicationName,
        med.medicineName,
        newIngredients,
        existingIngredients,
      );
      if (ingredientWarning != null) {
        warnings.add(ingredientWarning);
        continue;
      }

      final nameWarning = _checkNameConflict(
        medicationName,
        med.medicineName,
      );
      if (nameWarning != null) {
        warnings.add(nameWarning);
      }
    }

    // AI deep check for interactions missed by local rules
    if (existing.isNotEmpty) {
      final aiWarnings = await _checkWithAi(
        medicationName,
        existing,
        activeIngredients,
      );
      for (final ai in aiWarnings) {
        final alreadyFound = warnings.any(
          (w) =>
              w.medication2.toLowerCase() == ai.medication2.toLowerCase() ||
              w.medication1.toLowerCase() == ai.medication2.toLowerCase(),
        );
        if (!alreadyFound) warnings.add(ai);
      }
    }

    warnings.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return warnings;
  }

  List<String> _parseIngredients(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',').map((e) => e.trim().toLowerCase()).toList();
  }

  InteractionWarning? _checkCategoryConflict(
    String name1,
    String name2,
    String cat1,
    String cat2,
  ) {
    if (cat1.isEmpty || cat2.isEmpty) return null;

    final conflicts = _categoryConflicts[cat1];
    if (conflicts == null) return null;

    for (final conflict in conflicts) {
      if (cat2.contains(conflict)) {
        return InteractionWarning(
          medication1: name1,
          medication2: name2,
          severity: InteractionSeverity.major,
          description:
              'Both medications belong to conflicting categories ($cat1 + $cat2). '
              'Using them together increases risk of adverse effects.',
          recommendation:
              'Consult your doctor before taking these medications together.',
        );
      }
    }
    return null;
  }

  InteractionWarning? _checkIngredientConflict(
    String name1,
    String name2,
    List<String> ingredients1,
    List<String> ingredients2,
  ) {
    for (final ing1 in ingredients1) {
      final conflicts = _ingredientConflicts[ing1];
      if (conflicts == null) continue;
      for (final ing2 in ingredients2) {
        if (conflicts.contains(ing2)) {
          final key1 = '$ing1:$ing2';
          final key2 = '$ing2:$ing1';
          final severity = _knownSeverities[key1] ??
              _knownSeverities[key2] ??
              InteractionSeverity.moderate;
          return InteractionWarning(
            medication1: name1,
            medication2: name2,
            severity: severity,
            description:
                'Active ingredient $ing1 interacts with $ing2.',
            recommendation:
                'Consult your doctor or pharmacist about this combination.',
          );
        }
      }
    }

    // Same ingredient in both
    for (final ing1 in ingredients1) {
      if (ingredients2.contains(ing1)) {
        return InteractionWarning(
          medication1: name1,
          medication2: name2,
          severity: InteractionSeverity.major,
          description:
              'Both medications contain $ing1. Taking both may cause overdose.',
          recommendation: 'Do not take both without doctor approval.',
        );
      }
    }

    return null;
  }

  InteractionWarning? _checkNameConflict(String name1, String name2) {
    final n1 = name1.toLowerCase().trim();
    final n2 = name2.toLowerCase().trim();
    final conflicts = _ingredientConflicts[n1];
    if (conflicts != null && conflicts.contains(n2)) {
      final key1 = '$n1:$n2';
      final key2 = '$n2:$n1';
      final severity = _knownSeverities[key1] ??
          _knownSeverities[key2] ??
          InteractionSeverity.moderate;
      return InteractionWarning(
        medication1: name1,
        medication2: name2,
        severity: severity,
        description: '$name1 may interact with $name2.',
        recommendation:
            'Consult your doctor or pharmacist about this combination.',
      );
    }
    return null;
  }

  Future<List<InteractionWarning>> _checkWithAi(
    String newDrug,
    List<Medication> existing,
    String? newIngredients,
  ) async {
    try {
      final drugNames = existing.map((m) => m.medicineName).toList();
      final ingredientMap = <String, String>{};
      for (final m in existing) {
        if (m.activeIngredients != null) {
          ingredientMap[m.medicineName] = m.activeIngredients!;
        }
      }
      if (newIngredients != null) {
        ingredientMap[newDrug] = newIngredients;
      }

      final results = await AiDrugInfoService().checkInteractions(
        newDrug: newDrug,
        existingDrugs: drugNames,
        drugIngredients: ingredientMap,
      );

      return results.map((r) {
        final severity = _parseSeverity(r.severity);
        return InteractionWarning(
          medication1: r.drug1.isNotEmpty ? r.drug1 : newDrug,
          medication2: r.drug2,
          severity: severity,
          description: r.description,
          recommendation: r.recommendation,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  InteractionSeverity _parseSeverity(String value) {
    switch (value.toLowerCase()) {
      case 'minor':
        return InteractionSeverity.minor;
      case 'major':
        return InteractionSeverity.major;
      case 'severe':
        return InteractionSeverity.severe;
      default:
        return InteractionSeverity.moderate;
    }
  }

  List<InteractionWarning> _checkLocalInteractions(List<Medication> meds) {
    final warnings = <InteractionWarning>[];
    for (var i = 0; i < meds.length; i++) {
      for (var j = i + 1; j < meds.length; j++) {
        final ing1 = _parseIngredients(meds[i].activeIngredients);
        final ing2 = _parseIngredients(meds[j].activeIngredients);
        final cat1 = meds[i].drugCategory?.toLowerCase().trim() ?? '';
        final cat2 = meds[j].drugCategory?.toLowerCase().trim() ?? '';

        final catW = _checkCategoryConflict(
          meds[i].medicineName,
          meds[j].medicineName,
          cat1,
          cat2,
        );
        if (catW != null) {
          warnings.add(catW);
          continue;
        }

        final ingW = _checkIngredientConflict(
          meds[i].medicineName,
          meds[j].medicineName,
          ing1,
          ing2,
        );
        if (ingW != null) {
          warnings.add(ingW);
          continue;
        }

        final nameW = _checkNameConflict(
          meds[i].medicineName,
          meds[j].medicineName,
        );
        if (nameW != null) warnings.add(nameW);
      }
    }
    warnings.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return warnings;
  }

  Future<bool> hasSevereInteractions() async {
    final warnings = await checkAllInteractions();
    return warnings.any(
      (w) =>
          w.severity == InteractionSeverity.severe ||
          w.severity == InteractionSeverity.major,
    );
  }

  Future<Map<InteractionSeverity, int>> getInteractionCounts() async {
    final warnings = await checkAllInteractions();
    final counts = <InteractionSeverity, int>{
      for (final s in InteractionSeverity.values) s: 0,
    };
    for (final w in warnings) {
      counts[w.severity] = (counts[w.severity] ?? 0) + 1;
    }
    return counts;
  }

  static String getSeverityLabel(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.minor:
        return 'Minor';
      case InteractionSeverity.moderate:
        return 'Moderate';
      case InteractionSeverity.major:
        return 'Major';
      case InteractionSeverity.severe:
        return 'Severe';
    }
  }

  static String getSeverityDescription(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.minor:
        return 'Monitor for side effects';
      case InteractionSeverity.moderate:
        return 'Use with caution';
      case InteractionSeverity.major:
        return 'Avoid if possible';
      case InteractionSeverity.severe:
        return 'Do not combine';
    }
  }
}
