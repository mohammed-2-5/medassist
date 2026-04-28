import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/drug_name_normalizer.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/ai/ai_drug_info_service.dart';

class InteractionWarning {
  InteractionWarning({
    required this.medication1,
    required this.medication2,
    required this.severity,
    required this.description,
    required this.recommendation,
    this.descriptionAr,
    this.recommendationAr,
    this.evidence,
    this.medication1Id,
    this.medication2Id,
  });

  final String medication1;
  final String medication2;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;

  final String? descriptionAr;
  final String? recommendationAr;
  final String? evidence;

  /// medication1Id is null until the new med is inserted; medication2Id
  /// is the existing med it conflicts with.
  final int? medication1Id;
  final int? medication2Id;

  String descriptionFor(String languageCode) {
    final ar = descriptionAr;
    if (languageCode.toLowerCase().startsWith('ar') &&
        ar != null &&
        ar.trim().isNotEmpty) {
      return ar;
    }
    return description;
  }

  String recommendationFor(String languageCode) {
    final ar = recommendationAr;
    if (languageCode.toLowerCase().startsWith('ar') &&
        ar != null &&
        ar.trim().isNotEmpty) {
      return ar;
    }
    return recommendation;
  }

  InteractionWarning copyWithIds({int? medication1Id, int? medication2Id}) {
    return InteractionWarning(
      medication1: medication1,
      medication2: medication2,
      severity: severity,
      description: description,
      recommendation: recommendation,
      descriptionAr: descriptionAr,
      recommendationAr: recommendationAr,
      evidence: evidence,
      medication1Id: medication1Id ?? this.medication1Id,
      medication2Id: medication2Id ?? this.medication2Id,
    );
  }

  @override
  String toString() => '$medication1 + $medication2: $description';
}

enum InteractionSeverity {
  minor,
  moderate,
  major,
  severe,
}

/// Context for a single medication used when checking interactions.
/// Dose/frequency optional — when provided, dose-aware rules can fire.
class MedicationInteractionContext {
  const MedicationInteractionContext({
    required this.name,
    this.activeIngredients,
    this.drugCategory,
    this.strength,
    this.dosePerTime,
    this.timesPerDay,
    this.reminderMinutes,
  });

  factory MedicationInteractionContext.fromMedication(
    Medication med, {
    List<int>? reminderMinutes,
  }) {
    return MedicationInteractionContext(
      name: med.medicineName,
      activeIngredients: med.activeIngredients,
      drugCategory: med.drugCategory,
      strength: med.strength,
      dosePerTime: med.dosePerTime,
      timesPerDay: med.timesPerDay,
      reminderMinutes: reminderMinutes,
    );
  }

  final String name;
  final String? activeIngredients;
  final String? drugCategory;
  final String? strength;
  final double? dosePerTime;
  final int? timesPerDay;
  /// Reminder times expressed as minutes since midnight (0–1439). Used to
  /// compute the closest gap between this med's doses and another med's doses
  /// — interactions that depend on absorption/timing get worse if the user
  /// takes them within a few hours of each other.
  final List<int>? reminderMinutes;

  /// Estimated total mg consumed per day, when strength is parseable.
  double? get dailyMg {
    final mg = DrugNameNormalizer.strengthInMg(strength);
    if (mg == null) return null;
    final perDose = dosePerTime ?? 1;
    final times = timesPerDay ?? 1;
    return mg * perDose * times;
  }
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
    // Calcium channel blockers + beta blockers = bradycardia / heart block.
    'verapamil': [
      'nebivolol',
      'metoprolol',
      'atenolol',
      'bisoprolol',
      'propranolol',
      'carvedilol',
      'digoxin',
    ],
    'diltiazem': [
      'nebivolol',
      'metoprolol',
      'atenolol',
      'bisoprolol',
      'propranolol',
      'carvedilol',
    ],
    // Centrally-acting muscle relaxants (Relaxon = chlorzoxazone) — additive
    // CNS depression with sedatives/opioids/benzos AND additive GI + liver
    // stress with NSAIDs.
    'chlorzoxazone': [
      'diclofenac',
      'ibuprofen',
      'naproxen',
      'aspirin',
      'tramadol',
      'paracetamol',
      'alcohol',
      'diazepam',
      'alprazolam',
    ],
    'orphenadrine': ['diclofenac', 'ibuprofen', 'tramadol', 'alcohol'],
    'tizanidine': ['ciprofloxacin', 'fluvoxamine', 'alcohol'],
    'methocarbamol': ['alcohol', 'tramadol'],
    // Paracetamol — additive GI/bleeding with NSAIDs when taken close together.
    // Local engine flags timing-only; AI prompt still says paracetamol+NSAID
    // at standard doses is safe; the timing-aware additive rule covers the
    // doses-too-close case the user reported.
    'paracetamol': ['chlorzoxazone'],
    'acetaminophen': ['chlorzoxazone'],
    'nebivolol': ['verapamil', 'diltiazem'],
    'metoprolol': ['verapamil', 'diltiazem'],
    'atenolol': ['verapamil', 'diltiazem'],
    'bisoprolol': ['verapamil', 'diltiazem'],
    'propranolol': ['verapamil', 'diltiazem'],
    'carvedilol': ['verapamil', 'diltiazem'],
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
    // CCB + beta-blocker = severe (bradycardia / AV block / heart failure).
    'verapamil:nebivolol': InteractionSeverity.severe,
    'verapamil:metoprolol': InteractionSeverity.severe,
    'verapamil:atenolol': InteractionSeverity.severe,
    'verapamil:bisoprolol': InteractionSeverity.severe,
    'verapamil:propranolol': InteractionSeverity.severe,
    'verapamil:carvedilol': InteractionSeverity.severe,
    'diltiazem:nebivolol': InteractionSeverity.severe,
    'diltiazem:metoprolol': InteractionSeverity.severe,
    'diltiazem:atenolol': InteractionSeverity.severe,
    'diltiazem:bisoprolol': InteractionSeverity.severe,
    'diltiazem:propranolol': InteractionSeverity.severe,
    'diltiazem:carvedilol': InteractionSeverity.severe,
    // Muscle relaxants combined with NSAIDs / opioids / sedatives.
    'chlorzoxazone:diclofenac': InteractionSeverity.major,
    'chlorzoxazone:ibuprofen': InteractionSeverity.major,
    'chlorzoxazone:naproxen': InteractionSeverity.major,
    'chlorzoxazone:tramadol': InteractionSeverity.major,
    'chlorzoxazone:alcohol': InteractionSeverity.major,
    'chlorzoxazone:paracetamol': InteractionSeverity.moderate,
    'orphenadrine:tramadol': InteractionSeverity.major,
  };

  /// Ingredients with well-established safety profile that are routinely
  /// mis-flagged by generic AI prompts. We skip AI warnings that pair one
  /// of these with an ingredient NOT in its curated danger list.
  static const Map<String, Set<String>> _safeIngredientAllowlist = {
    'paracetamol': {'warfarin', 'phenytoin', 'isoniazid', 'carbamazepine'},
    'acetaminophen': {'warfarin', 'phenytoin', 'isoniazid', 'carbamazepine'},
    'vitamin c': {},
    'vitamin d': {'thiazide', 'calcium'},
    'vitamin b': {},
    'zinc': {'ciprofloxacin', 'tetracycline'},
  };

  /// Egyptian-Arabic display names for English category keys used in rule-
  /// based warnings. Falls back to the English key when missing.
  static const Map<String, String> _categoryAr = {
    'nsaid': 'مسكنات NSAID',
    'anticoagulant': 'سيولة الدم',
    'blood thinner': 'سيولة الدم',
    'antiplatelet': 'مضاد للصفائح',
    'ace inhibitor': 'مثبط ACE',
    'arb': 'حاصر مستقبلات أنجيوتنسين',
    'potassium-sparing diuretic': 'مدر بول حافظ للبوتاسيوم',
    'ssri': 'مضاد اكتئاب SSRI',
    'maoi': 'مضاد اكتئاب MAOI',
    'snri': 'مضاد اكتئاب SNRI',
    'tca': 'مضاد اكتئاب TCA',
  };

  /// Egyptian-Arabic display names for common ingredient keys.
  static const Map<String, String> _ingredientAr = {
    'paracetamol': 'باراسيتامول',
    'acetaminophen': 'باراسيتامول',
    'ibuprofen': 'إيبوبروفين',
    'aspirin': 'أسبرين',
    'naproxen': 'نابروكسين',
    'diclofenac': 'ديكلوفيناك',
    'warfarin': 'وارفارين',
    'heparin': 'هيبارين',
    'tramadol': 'ترامادول',
    'sertraline': 'سيرترالين',
    'fluoxetine': 'فلوكستين',
    'citalopram': 'سيتالوبرام',
    'lithium': 'ليثيوم',
    'methotrexate': 'ميثوتركسات',
    'metformin': 'ميتفورمين',
    'lisinopril': 'ليزينوبريل',
    'losartan': 'لوسارتان',
    'simvastatin': 'سيمفاستاتين',
    'atorvastatin': 'أتورفاستاتين',
    'amlodipine': 'أملوديبين',
    'clarithromycin': 'كلاريثروميسين',
    'ciprofloxacin': 'سيبروفلوكساسين',
    'theophylline': 'ثيوفيلين',
    'digoxin': 'ديجوكسين',
    'amiodarone': 'أميودارون',
    'verapamil': 'فيراباميل',
    'levothyroxine': 'ليفوثيروكسين',
    'calcium': 'كالسيوم',
    'iron': 'حديد',
    'potassium': 'بوتاسيوم',
    'amoxicillin': 'أموكسيسيلين',
    'phenytoin': 'فينيتوين',
    'isoniazid': 'إيزونيازيد',
    'carbamazepine': 'كاربامازيبين',
  };

  static String _ar(Map<String, String> map, String key) {
    return map[key.toLowerCase().trim()] ?? key;
  }

  /// Max safe daily dose per ingredient (mg). Used for overdose detection
  /// when same ingredient appears across multiple medications.
  static const Map<String, double> _dailyMgLimits = {
    'paracetamol': 4000,
    'acetaminophen': 4000,
    'ibuprofen': 2400,
    'naproxen': 1000,
    'aspirin': 4000,
    'diclofenac': 150,
    'caffeine': 400,
  };

  Future<List<InteractionWarning>> checkAllInteractions() async {
    final medications = await _database.getAllMedications();
    return _checkLocalInteractions(medications);
  }

  Future<List<InteractionWarning>> checkNewMedication(
    String medicationName, {
    String? activeIngredients,
    String? drugCategory,
    String? strength,
    double? dosePerTime,
    int? timesPerDay,
    List<int>? reminderMinutes,
  }) async {
    final existing = await _database.getAllMedications();
    final newCtx = MedicationInteractionContext(
      name: medicationName,
      activeIngredients: activeIngredients,
      drugCategory: drugCategory,
      strength: strength,
      dosePerTime: dosePerTime,
      timesPerDay: timesPerDay,
      reminderMinutes: reminderMinutes,
    );
    final warnings = <InteractionWarning>[];

    final newIngredients = _parseIngredients(activeIngredients);
    final newCategory = drugCategory?.toLowerCase().trim() ?? '';

    for (final med in existing) {
      // Load this med's reminder times so the additive check can use the
      // smallest hours-apart between any pair of reminder times.
      final reminders = await _database.getReminderTimes(med.id);
      final existingMinutes = reminders
          .map((r) => r.hour * 60 + r.minute)
          .toList();
      final existingCtx = MedicationInteractionContext.fromMedication(
        med,
        reminderMinutes: existingMinutes,
      );
      final existingIngredients = _parseIngredients(med.activeIngredients);
      final existingCategory = med.drugCategory?.toLowerCase().trim() ?? '';

      final overdoseWarn = _checkOverdose(newCtx, existingCtx);
      if (overdoseWarn != null) {
        warnings.add(overdoseWarn.copyWithIds(medication2Id: med.id));
        continue;
      }

      final categoryWarning = _checkCategoryConflict(
        medicationName,
        med.medicineName,
        newCategory,
        existingCategory,
      );
      if (categoryWarning != null) {
        warnings.add(categoryWarning.copyWithIds(medication2Id: med.id));
        continue;
      }

      final additiveWarning = _checkSameCategoryAdditive(newCtx, existingCtx);
      if (additiveWarning != null) {
        warnings.add(additiveWarning.copyWithIds(medication2Id: med.id));
        continue;
      }

      final ingredientWarning = _checkIngredientConflict(
        medicationName,
        med.medicineName,
        newIngredients,
        existingIngredients,
      );
      if (ingredientWarning != null) {
        warnings.add(ingredientWarning.copyWithIds(medication2Id: med.id));
        continue;
      }

      final nameWarning = _checkNameConflict(
        medicationName,
        med.medicineName,
      );
      if (nameWarning != null) {
        warnings.add(nameWarning.copyWithIds(medication2Id: med.id));
      }
    }

    // Solo-overdose: new med alone exceeds daily limit
    final soloOverdose = _checkSoloOverdose(newCtx);
    if (soloOverdose != null) warnings.add(soloOverdose);

    // AI deep check — dose-aware prompt, filtered through allowlist
    if (existing.isNotEmpty) {
      final aiWarnings = await _checkWithAi(newCtx, existing);
      for (final ai in aiWarnings) {
        final alreadyFound = warnings.any(
          (w) =>
              w.medication2.toLowerCase() == ai.medication2.toLowerCase() ||
              w.medication1.toLowerCase() == ai.medication2.toLowerCase(),
        );
        if (!alreadyFound) warnings.add(ai);
      }
      _dedupePairs(warnings);
    }

    warnings.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return warnings;
  }

  List<String> _parseIngredients(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    return raw
        .split(RegExp('[,،؛]'))
        .map((e) => DrugNameNormalizer.canonicalName(e).trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Categories where stacking two drugs of the same family causes additive
  // risk (more BP drop, more bleeding, more sedation, etc.). Matched as a
  // substring against either drug's drugCategory.
  static const List<String> _additiveCategories = [
    'antihypertensive',
    'blood pressure',
    'ضغط',
    'beta blocker',
    'beta-blocker',
    'calcium channel blocker',
    'ace inhibitor',
    'arb',
    'diuretic',
    'مدر',
    'anticoagulant',
    'blood thinner',
    'مميع',
    'sedative',
    'benzodiazepine',
    'opioid',
    'مسكن',
    'insulin',
    'antidiabetic',
    'سكر',
  ];

  /// Returns the smallest gap (in hours, 0–12) between any reminder time of
  /// [a] and any reminder time of [b], on a circular 24h clock. Returns null
  /// if either side has no times.
  static double? _minHoursApart(
    List<int>? aMinutes,
    List<int>? bMinutes,
  ) {
    if (aMinutes == null || aMinutes.isEmpty) return null;
    if (bMinutes == null || bMinutes.isEmpty) return null;
    var minDiff = 24 * 60;
    for (final a in aMinutes) {
      for (final b in bMinutes) {
        final raw = (a - b).abs();
        final circular = raw > 12 * 60 ? 24 * 60 - raw : raw;
        if (circular < minDiff) minDiff = circular;
      }
    }
    return minDiff / 60.0;
  }

  /// Painkiller / sedative / anticoagulant categories where dose timing
  /// changes the risk: <3h apart = major, 3–6h = moderate, >6h = minor/skip.
  static const Set<String> _timingSensitiveMarkers = {
    'مسكن',
    'opioid',
    'sedative',
    'benzodiazepine',
    'anticoagulant',
    'blood thinner',
    'مميع',
  };

  InteractionWarning? _checkSameCategoryAdditive(
    MedicationInteractionContext a,
    MedicationInteractionContext b,
  ) {
    final cat1 = a.drugCategory?.toLowerCase().trim() ?? '';
    final cat2 = b.drugCategory?.toLowerCase().trim() ?? '';
    if (cat1.isEmpty || cat2.isEmpty) return null;

    for (final marker in _additiveCategories) {
      if (!cat1.contains(marker) || !cat2.contains(marker)) continue;

      final hoursApart = _minHoursApart(a.reminderMinutes, b.reminderMinutes);
      final isTimingSensitive = _timingSensitiveMarkers.contains(marker);

      // For painkillers/anticoagulants/sedatives: if doses are spaced ≥6h
      // apart, additive risk is minimal — skip the warning.
      if (isTimingSensitive &&
          hoursApart != null &&
          hoursApart >= 6) {
        continue;
      }

      var severity = InteractionSeverity.moderate;
      if (isTimingSensitive && hoursApart != null && hoursApart < 3) {
        severity = InteractionSeverity.major;
      }

      final timingEn = hoursApart == null
          ? ''
          : ' You take them about ${hoursApart.toStringAsFixed(hoursApart == hoursApart.roundToDouble() ? 0 : 1)}h apart.';
      final timingAr = hoursApart == null
          ? ''
          : ' بتاخدهم بفرق حوالي ${hoursApart.toStringAsFixed(hoursApart == hoursApart.roundToDouble() ? 0 : 1)} ساعة بين الجرعتين.';

      final extraEn = isTimingSensitive && hoursApart != null && hoursApart < 4
          ? ' Try to space them at least 4–6 hours apart.'
          : '';
      final extraAr = isTimingSensitive && hoursApart != null && hoursApart < 4
          ? ' حاول تباعد بينهم 4-6 ساعات على الأقل.'
          : '';

      return InteractionWarning(
        medication1: a.name,
        medication2: b.name,
        severity: severity,
        description:
            'Both medications are in the same family ($marker).$timingEn '
            'Combined effects (GI irritation, sedation, bleeding risk depending on the class) may be stronger than expected.',
        recommendation:
            'Monitor for side effects.$extraEn Consult your doctor or pharmacist.',
        descriptionAr:
            'الدوايتين من نفس الفصيلة (${_ar(_categoryAr, marker)}).$timingAr '
            'أخدهم مع بعض ممكن يزود الأعراض (تهيج معدة، نعاس، أو نزيف حسب نوع الدوا).',
        recommendationAr:
            'تابع نفسك كويس.$extraAr استشير طبيبك أو الصيدلي.',
        evidence: hoursApart == null
            ? 'same-category additive: $marker'
            : 'same-category additive: $marker (${hoursApart.toStringAsFixed(1)}h apart)',
      );
    }
    return null;
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
          descriptionAr:
              'الدوايتين من فصايل متعارضة (${_ar(_categoryAr, cat1)} + '
              '${_ar(_categoryAr, cat2)})، وأخدهم مع بعض ممكن '
              'يزود فرصة الأعراض الجانبية.',
          recommendationAr:
              'الأفضل ميتاخدوش مع بعض من غير ما تستشير طبيبك أو الصيدلي الأول.',
          evidence: 'category: $cat1 + $cat2',
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
          final severity =
              _knownSeverities[key1] ??
              _knownSeverities[key2] ??
              InteractionSeverity.moderate;
          return InteractionWarning(
            medication1: name1,
            medication2: name2,
            severity: severity,
            description: 'Active ingredient $ing1 interacts with $ing2.',
            recommendation:
                'Consult your doctor or pharmacist about this combination.',
            descriptionAr:
                'المادة الفعالة ${_ar(_ingredientAr, ing1)} ممكن تتفاعل مع '
                '${_ar(_ingredientAr, ing2)}.',
            recommendationAr:
                'الأفضل تستشير طبيبك أو الصيدلي قبل ما تاخدهم مع بعض.',
            evidence: '$ing1 + $ing2',
          );
        }
      }
    }

    for (final ing1 in ingredients1) {
      if (ingredients2.contains(ing1)) {
        return InteractionWarning(
          medication1: name1,
          medication2: name2,
          severity: InteractionSeverity.major,
          description:
              'Both medications contain $ing1. Taking both may cause overdose.',
          recommendation: 'Do not take both without doctor approval.',
          descriptionAr:
              'الدوايتين فيهم نفس المادة (${_ar(_ingredientAr, ing1)})، يعني '
              'أخدهم مع بعض ممكن يخليك تاخد جرعة زيادة.',
          recommendationAr:
              'متاخدش الاتنين مع بعض من غير ما تستشير طبيبك أو الصيدلي.',
          evidence: 'duplicate ingredient: $ing1',
        );
      }
    }

    return null;
  }

  InteractionWarning? _checkNameConflict(String name1, String name2) {
    final n1 = DrugNameNormalizer.canonicalName(name1);
    final n2 = DrugNameNormalizer.canonicalName(name2);
    final conflicts = _ingredientConflicts[n1];
    if (conflicts != null && conflicts.contains(n2)) {
      final key1 = '$n1:$n2';
      final key2 = '$n2:$n1';
      final severity =
          _knownSeverities[key1] ??
          _knownSeverities[key2] ??
          InteractionSeverity.moderate;
      return InteractionWarning(
        medication1: name1,
        medication2: name2,
        severity: severity,
        description: '$name1 may interact with $name2.',
        recommendation:
            'Consult your doctor or pharmacist about this combination.',
        descriptionAr: '$name1 ممكن يتفاعل مع $name2.',
        recommendationAr:
            'الأفضل تستشير طبيبك أو الصيدلي قبل ما تاخدهم مع بعض.',
        evidence: '$n1 + $n2',
      );
    }
    return null;
  }

  /// Detect shared-ingredient daily-mg overdose across two meds.
  InteractionWarning? _checkOverdose(
    MedicationInteractionContext a,
    MedicationInteractionContext b,
  ) {
    final ingA = _parseIngredients(a.activeIngredients);
    final ingB = _parseIngredients(b.activeIngredients);
    final aMg = a.dailyMg;
    final bMg = b.dailyMg;
    if (aMg == null || bMg == null) return null;

    for (final ing in ingA) {
      if (!ingB.contains(ing)) continue;
      final limit = _dailyMgLimits[ing];
      if (limit == null) continue;
      final total = aMg + bMg;
      if (total <= limit) continue;
      return InteractionWarning(
        medication1: a.name,
        medication2: b.name,
        severity: InteractionSeverity.severe,
        description:
            'Combined daily intake of $ing is ${total.toStringAsFixed(0)} mg, '
            'above the safe limit of ${limit.toStringAsFixed(0)} mg/day.',
        recommendation:
            'Reduce one of the medications or consult your doctor before combining.',
        descriptionAr:
            'مجموع جرعة ${_ar(_ingredientAr, ing)} اليومية '
            '${total.toStringAsFixed(0)} مج، وده فوق الحد الآمن '
            '${limit.toStringAsFixed(0)} مج في اليوم.',
        recommendationAr:
            'قلل جرعة من الدوايتين أو استشير طبيبك قبل ما تاخدهم مع بعض.',
        evidence:
            '$ing: ${aMg.toStringAsFixed(0)}+${bMg.toStringAsFixed(0)} > $limit mg/day',
      );
    }
    return null;
  }

  InteractionWarning? _checkSoloOverdose(MedicationInteractionContext ctx) {
    final mg = ctx.dailyMg;
    if (mg == null) return null;
    final ingredients = _parseIngredients(ctx.activeIngredients);
    final candidates = ingredients.isEmpty
        ? [DrugNameNormalizer.canonicalName(ctx.name)]
        : ingredients;
    for (final ing in candidates) {
      final limit = _dailyMgLimits[ing];
      if (limit == null) continue;
      if (mg <= limit) continue;
      return InteractionWarning(
        medication1: ctx.name,
        medication2: ctx.name,
        severity: InteractionSeverity.severe,
        description:
            'Scheduled daily dose of $ing is ${mg.toStringAsFixed(0)} mg, '
            'above the safe limit of ${limit.toStringAsFixed(0)} mg/day.',
        recommendation: 'Lower the dose or frequency, or consult your doctor.',
        descriptionAr:
            'الجرعة اليومية من ${_ar(_ingredientAr, ing)} '
            '${mg.toStringAsFixed(0)} مج، وده فوق الحد الآمن '
            '${limit.toStringAsFixed(0)} مج في اليوم.',
        recommendationAr: 'قلل الجرعة أو المرات، والأفضل تستشير طبيبك.',
        evidence: '$ing: ${mg.toStringAsFixed(0)} > $limit mg/day',
      );
    }
    return null;
  }

  Future<List<InteractionWarning>> _checkWithAi(
    MedicationInteractionContext newCtx,
    List<Medication> existing,
  ) async {
    try {
      final existingCtx = existing
          .map(MedicationInteractionContext.fromMedication)
          .toList();

      final results = await AiDrugInfoService().checkInteractions(
        newDrug: newCtx,
        existingDrugs: existingCtx,
      );

      final filtered = results.where(_passesSafetyAllowlist).toList();

      return filtered.map((r) {
        final severity = _parseSeverity(r.severity);
        final matchedId =
            _matchExistingId(r.drug2, existing) ??
            _matchExistingId(r.drug1, existing);
        return InteractionWarning(
          medication1: r.drug1.isNotEmpty ? r.drug1 : newCtx.name,
          medication2: r.drug2,
          severity: severity,
          description: r.description,
          recommendation: r.recommendation,
          descriptionAr: r.descriptionAr.isNotEmpty ? r.descriptionAr : null,
          recommendationAr: r.recommendationAr.isNotEmpty
              ? r.recommendationAr
              : null,
          evidence: r.evidence.isNotEmpty ? r.evidence : null,
          medication2Id: matchedId,
        );
      }).toList();
    } on Object {
      return [];
    }
  }

  int? _matchExistingId(String drugName, List<Medication> meds) {
    if (drugName.isEmpty) return null;
    final target = drugName.toLowerCase().trim();
    if (target.isEmpty) return null;

    // 1. Exact medicine-name match.
    for (final med in meds) {
      if (med.medicineName.toLowerCase().trim() == target) return med.id;
    }

    // 2. Fuzzy match: AI usually returns generic/ingredient names while the
    // user saved a brand name (e.g. AI says "Paracetamol", user has "Panadol").
    // Match against generic name, active ingredients, and brand name in either
    // direction (substring), so brand <-> ingredient pairs are linked.
    for (final med in meds) {
      final brand = med.medicineName.toLowerCase().trim();
      final generic = (med.genericName ?? '').toLowerCase().trim();
      final ingredients = (med.activeIngredients ?? '').toLowerCase();

      if (generic.isNotEmpty &&
          (generic == target ||
              generic.contains(target) ||
              target.contains(generic))) {
        return med.id;
      }
      if (ingredients.isNotEmpty && ingredients.contains(target)) {
        return med.id;
      }
      if (brand.contains(target) || target.contains(brand)) {
        return med.id;
      }
    }
    return null;
  }

  /// Drop duplicate pairs (drug1+drug2 == drug2+drug1) keeping highest severity.
  void _dedupePairs(List<InteractionWarning> warnings) {
    final seen = <String, int>{};
    final indexesToRemove = <int>[];
    for (var i = 0; i < warnings.length; i++) {
      final w = warnings[i];
      final a = w.medication1.toLowerCase().trim();
      final b = w.medication2.toLowerCase().trim();
      final key = a.compareTo(b) < 0 ? '$a|$b' : '$b|$a';
      final prev = seen[key];
      if (prev == null) {
        seen[key] = i;
      } else if (warnings[i].severity.index > warnings[prev].severity.index) {
        indexesToRemove.add(prev);
        seen[key] = i;
      } else {
        indexesToRemove.add(i);
      }
    }
    indexesToRemove.sort((a, b) => b.compareTo(a));
    for (final idx in indexesToRemove) {
      warnings.removeAt(idx);
    }
  }

  /// Reject AI hits that pair a safe ingredient with one NOT in its curated
  /// danger set. Catches common hallucinations like paracetamol↔anticoagulant.
  bool _passesSafetyAllowlist(AiInteractionResult r) {
    final text = '${r.drug1} ${r.drug2} ${r.description} ${r.evidence}'
        .toLowerCase();
    for (final entry in _safeIngredientAllowlist.entries) {
      if (!text.contains(entry.key)) continue;
      final danger = entry.value;
      if (danger.isEmpty) return false;
      final hasDanger = danger.any(text.contains);
      if (!hasDanger) return false;
    }
    return true;
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
        final ctxI = MedicationInteractionContext.fromMedication(meds[i]);
        final ctxJ = MedicationInteractionContext.fromMedication(meds[j]);

        final overdose = _checkOverdose(ctxI, ctxJ);
        if (overdose != null) {
          warnings.add(overdose);
          continue;
        }

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

  static String severityLabel(
    InteractionSeverity severity,
    AppLocalizations l10n,
  ) {
    switch (severity) {
      case InteractionSeverity.minor:
        return l10n.severityMinor;
      case InteractionSeverity.moderate:
        return l10n.severityModerate;
      case InteractionSeverity.major:
        return l10n.severityMajor;
      case InteractionSeverity.severe:
        return l10n.severitySevere;
    }
  }

  static String severityDescription(
    InteractionSeverity severity,
    AppLocalizations l10n,
  ) {
    switch (severity) {
      case InteractionSeverity.minor:
        return l10n.severityMinorDesc;
      case InteractionSeverity.moderate:
        return l10n.severityModerateDesc;
      case InteractionSeverity.major:
        return l10n.severityMajorDesc;
      case InteractionSeverity.severe:
        return l10n.severitySevereDesc;
    }
  }
}
