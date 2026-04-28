import 'dart:convert';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/models/meal_timing.dart';
import 'package:med_assist/core/utils/drug_name_normalizer.dart';
import 'package:med_assist/services/ai/ai_prompt_sanitizer.dart';
import 'package:med_assist/services/ai/gemini_service.dart';
import 'package:med_assist/services/ai/groq_service.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart'
    show MedicationInteractionContext;
import 'package:med_assist/services/health/egyptian_drug_repository.dart';

class DrugInfoResult {
  const DrugInfoResult({
    this.genericName,
    this.activeIngredients,
    this.drugCategory,
    this.purpose,
    this.howToTake,
    this.bestTimeOfDay,
    this.commonSideEffects,
    this.drowsinessAffectsDriving,
    this.drowsinessWarning,
    this.alcoholWarning,
    this.contraindications,
    this.requiresMonitoring,
    this.foodsToAvoid,
    this.missedDoseAdvice,
    this.storageInstructions,
    this.warnings,
    this.otcOrPrescription,
    this.route,
  });

  Map<String, dynamic> toJson() => {
        'genericName': genericName,
        'activeIngredients': activeIngredients,
        'drugCategory': drugCategory,
        'purpose': purpose,
        'howToTake': howToTake,
        'bestTimeOfDay': bestTimeOfDay,
        'commonSideEffects': commonSideEffects,
        'drowsinessAffectsDriving': drowsinessAffectsDriving,
        'drowsinessWarningNote': drowsinessWarning,
        'alcoholWarning': alcoholWarning,
        'contraindications': contraindications,
        'requiresMonitoring': requiresMonitoring,
        'foodsToAvoid': foodsToAvoid,
        'missedDoseAdvice': missedDoseAdvice,
        'storageInstructions': storageInstructions,
        'drugWarnings': warnings,
        'otcOrPrescription': otcOrPrescription,
        'route': route,
      };

  factory DrugInfoResult.fromJson(Map<String, dynamic> json) {
    return DrugInfoResult(
      genericName: json['genericName'] as String?,
      activeIngredients: _parseList(json['activeIngredients']),
      drugCategory: _parseString(json['drugCategory'] ?? json['category']),
      purpose: _parseString(json['purpose']),
      howToTake: _parseString(json['howToTake']),
      bestTimeOfDay: _parseString(json['bestTimeOfDay']),
      commonSideEffects: _parseList(
        json['commonSideEffects'] ?? json['sideEffects'],
      ),
      drowsinessAffectsDriving: _parseBool(
        json['drowsinessAffectsDriving'] ?? json['drowsinessWarning'],
      ),
      drowsinessWarning: _parseString(
        json['drowsinessWarningNote'] ??
            (json['drowsinessWarning'] is String
                ? json['drowsinessWarning']
                : null),
      ),
      alcoholWarning: _parseString(json['alcoholWarning']),
      contraindications: _parseList(json['contraindications']),
      requiresMonitoring: _parseString(json['requiresMonitoring']),
      foodsToAvoid: _parseList(json['foodsToAvoid']),
      missedDoseAdvice: _parseString(json['missedDoseAdvice']),
      storageInstructions: _parseString(json['storageInstructions']),
      warnings: _parseList(json['drugWarnings'] ?? json['warnings']),
      otcOrPrescription: _parseString(json['otcOrPrescription']),
      route: _parseString(json['route']),
    );
  }

  final String? genericName;
  final List<String>? activeIngredients;
  final String? drugCategory;
  final String? purpose;
  final String? howToTake;
  final String? bestTimeOfDay;
  final List<String>? commonSideEffects;
  final bool? drowsinessAffectsDriving;
  final String? drowsinessWarning;
  final String? alcoholWarning;
  final List<String>? contraindications;
  final String? requiresMonitoring;
  final List<String>? foodsToAvoid;
  final String? missedDoseAdvice;
  final String? storageInstructions;
  final List<String>? warnings;
  final String? otcOrPrescription;
  final String? route;

  bool get isEmpty =>
      genericName == null &&
      activeIngredients == null &&
      drugCategory == null &&
      purpose == null &&
      howToTake == null &&
      bestTimeOfDay == null &&
      commonSideEffects == null &&
      drowsinessAffectsDriving == null &&
      drowsinessWarning == null &&
      alcoholWarning == null &&
      contraindications == null &&
      requiresMonitoring == null &&
      foodsToAvoid == null &&
      missedDoseAdvice == null &&
      storageInstructions == null &&
      warnings == null &&
      otcOrPrescription == null &&
      route == null;

  MealTiming inferMealTiming() {
    final text = howToTake?.toLowerCase().trim();
    if (text == null || text.isEmpty) return MealTiming.anytime;

    final beforeMealPatterns = <String>[
      'before meal',
      'before food',
      'empty stomach',
      'قبل الاكل',
      'قبل الأكل',
      'قبل الطعام',
    ];
    final withMealPatterns = <String>[
      'with meal',
      'with food',
      'during meal',
      'مع الاكل',
      'مع الأكل',
      'مع الطعام',
    ];
    final afterMealPatterns = <String>[
      'after meal',
      'after food',
      'بعد الاكل',
      'بعد الأكل',
      'بعد الطعام',
    ];

    if (beforeMealPatterns.any(text.contains)) return MealTiming.beforeMeal;
    if (withMealPatterns.any(text.contains)) return MealTiming.withMeal;
    if (afterMealPatterns.any(text.contains)) return MealTiming.afterMeal;
    return MealTiming.anytime;
  }

  // Qwen3 (Alibaba) occasionally leaks Chinese/Japanese/Korean tokens into
  // Arabic or English output. Strip CJK + CJK punctuation before saving.
  static final RegExp _cjkRegex = RegExp(
    r'[　-〿぀-ゟ゠-ヿ㐀-䶿一-鿿가-힯＀-￯]',
  );

  static String _stripCjk(String text) {
    return text
        .replaceAll(_cjkRegex, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final text = _stripCjk(value.toString());
    if (text.isEmpty) return null;
    return text;
  }

  static List<String>? _parseList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      final list = value
          .map((e) => _stripCjk(e.toString()))
          .where((e) => e.isNotEmpty)
          .toList();
      return list.isEmpty ? null : list;
    }
    if (value is String) {
      final list = _stripCjk(value)
          .split(RegExp(r'[,،؛\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (list.isEmpty) return null;
      return list;
    }
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower.isEmpty) return null;
      if (lower == 'true' || lower == 'yes' || lower == '1') return true;
      if (lower == 'false' || lower == 'no' || lower == '0') return false;
    }
    return null;
  }
}

class BilingualDrugInfoResult {
  const BilingualDrugInfoResult({
    this.en,
    this.ar,
    this.correctedName,
    this.suggestions = const [],
  });

  factory BilingualDrugInfoResult.fromJson(Map<String, dynamic> json) {
    final en = json['en'];
    final ar = json['ar'];
    final suggestions = json['suggestions'];
    return BilingualDrugInfoResult(
      en: en is Map<String, dynamic> ? DrugInfoResult.fromJson(en) : null,
      ar: ar is Map<String, dynamic> ? DrugInfoResult.fromJson(ar) : null,
      correctedName: json['correctedName'] as String?,
      suggestions: suggestions is List
          ? suggestions
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'en': en?.toJson(),
        'ar': ar?.toJson(),
        if (correctedName != null) 'correctedName': correctedName,
        if (suggestions.isNotEmpty) 'suggestions': suggestions,
      };

  final DrugInfoResult? en;
  final DrugInfoResult? ar;
  final String? correctedName;
  final List<String> suggestions;

  bool get hasData =>
      (en != null && !en!.isEmpty) || (ar != null && !ar!.isEmpty);

  bool get isEmpty => !hasData && suggestions.isEmpty;

  DrugInfoResult? forLanguage(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    if (isArabic) return ar ?? en;
    return en ?? ar;
  }
}

class AiInteractionResult {
  const AiInteractionResult({
    required this.drug1,
    required this.drug2,
    required this.severity,
    required this.description,
    required this.recommendation,
    this.descriptionAr = '',
    this.recommendationAr = '',
    this.evidence = '',
    this.neverCombine = false,
    this.hoursApart,
  });

  factory AiInteractionResult.fromJson(Map<String, dynamic> json) {
    String pickEn(String key, String keyEn) {
      final primary = json[keyEn];
      if (primary is String && primary.trim().isNotEmpty) return primary;
      final fallback = json[key];
      return fallback is String ? fallback : '';
    }

    return AiInteractionResult(
      drug1: json['drug1'] as String? ?? '',
      drug2: json['drug2'] as String? ?? '',
      severity: json['severity'] as String? ?? 'moderate',
      description: pickEn('description', 'descriptionEn'),
      recommendation: pickEn('recommendation', 'recommendationEn'),
      descriptionAr: json['descriptionAr'] as String? ?? '',
      recommendationAr: json['recommendationAr'] as String? ?? '',
      evidence: json['evidence'] as String? ?? '',
      neverCombine: json['neverCombine'] as bool? ?? false,
      hoursApart: (json['hoursApart'] as num?)?.toInt(),
    );
  }

  final String drug1;
  final String drug2;
  final String severity;
  final String description;
  final String recommendation;
  final String descriptionAr;
  final String recommendationAr;
  final String evidence;

  /// True when the combination is an absolute contraindication.
  final bool neverCombine;

  /// Required separation in hours for absorption-based interactions.
  final int? hoursApart;

  bool get isSevere => severity == 'severe' || neverCombine;
}

class AiDrugInfoService {
  factory AiDrugInfoService() => _instance;
  AiDrugInfoService._internal();
  static final AiDrugInfoService _instance = AiDrugInfoService._internal();

  final GroqService _groqService = GroqService();
  final GeminiService _geminiService = GeminiService();
  final EgyptianDrugRepository _egyptianDrugRepository =
      EgyptianDrugRepository(AppDatabase());
  final Map<String, BilingualDrugInfoResult?> _bilingualCache = {};

  Future<DrugInfoResult?> fetchDrugInfo(String drugName) async {
    final bilingual = await fetchDrugInfoBilingual(drugName);
    return bilingual?.en ?? bilingual?.ar;
  }

  Future<BilingualDrugInfoResult?> fetchDrugInfoBilingual(
    String drugName, {
    bool forceRefresh = false,
  }) async {
    final sanitizedRaw = AiPromptSanitizer.sanitizeUserMessage(drugName);
    if (sanitizedRaw.isEmpty) return null;

    // Normalize Arabic brand names to their English canonical form via the
    // local dictionary BEFORE asking the AI. Llama-class models have weak
    // recall on Arabic-script Egyptian brand names and tend to hallucinate
    // a "corrected" different drug (e.g. "كاتفلام" → "كافيتامين"). Using the
    // English canonical name avoids the misidentification entirely.
    final canonical = DrugNameNormalizer.canonicalName(sanitizedRaw);
    final isArabicInput = RegExp(r'[؀-ۿ]').hasMatch(sanitizedRaw);
    final isCanonicalLatin =
        canonical.isNotEmpty && !RegExp(r'[؀-ۿ]').hasMatch(canonical);
    final sanitized = (isArabicInput && isCanonicalLatin)
        ? canonical
        : sanitizedRaw;

    final cacheKey = sanitized.toLowerCase();
    if (forceRefresh) {
      _bilingualCache.remove(cacheKey);
      await _deletePersistentCache(cacheKey);
    } else {
      if (_bilingualCache.containsKey(cacheKey)) {
        return _bilingualCache[cacheKey];
      }
      final persisted = await _readPersistentCache(cacheKey);
      if (persisted != null) {
        _bilingualCache[cacheKey] = persisted;
        return persisted;
      }
    }

    // For known Egyptian brands the LLM doesn't recognize, query by active
    // ingredient first — that's what the AI actually has knowledge of. Keep
    // the original brand for display via correctedName.
    //
    // Lookup order:
    //   1. Local 26k Egyptian-drugs catalog (most authoritative — official
    //      EDA registry data, Arabic + English brand names supported).
    //   2. Hand-curated brandToIngredient map (small fallback for names
    //      that may not be in the catalog).
    final egyptianRecord = await _egyptianDrugRepository
        .findByBrand(sanitized)
        .catchError((Object _) => null);
    final ingredientLookup = egyptianRecord?.primaryIngredient ??
        DrugNameNormalizer.activeIngredientForBrand(sanitized);
    final aiQueryName = ingredientLookup ?? sanitized;
    final brandOverride = ingredientLookup != null ? sanitized : null;

    try {
      final response = await _tryGetResponse(_buildBilingualPrompt(aiQueryName));
      debugPrint('AiDrugInfoService: bilingual raw response for "$aiQueryName" = $response');
      if (response == null) return null;

      final json = _extractJson(response);
      debugPrint('AiDrugInfoService: bilingual parsed json keys = ${json?.keys.toList()}');
      var collectedSuggestions = <String>[];
      if (json != null) {
        if (json.containsKey('unknown')) {
          collectedSuggestions = _parseSuggestions(json['suggestions']);
        } else {
          final enJson = json['en'];
          final arJson = json['ar'];
          if (enJson is Map<String, dynamic> || arJson is Map<String, dynamic>) {
            // Reject AI "corrections" that are wildly different from the
            // input (Levenshtein-ish length-similarity gate). If the AI says
            // user typed "كاتفلام" but it "corrected" to "كافيتامين" — treat
            // as misidentification and surface as suggestion instead.
            final corrected = (json['correctedName'] as String?)?.trim();
            final mismatched = corrected != null &&
                corrected.isNotEmpty &&
                !_namesAreSimilar(sanitized, corrected);
            if (mismatched) {
              debugPrint(
                'AiDrugInfoService: rejecting suspicious correction '
                '"$sanitized" -> "$corrected"',
              );
              collectedSuggestions = [corrected];
            } else {
              final result = BilingualDrugInfoResult(
                en: enJson is Map<String, dynamic>
                    ? DrugInfoResult.fromJson(enJson)
                    : null,
                ar: arJson is Map<String, dynamic>
                    ? DrugInfoResult.fromJson(arJson)
                    : null,
                correctedName: corrected ?? brandOverride,
              );
              if (result.hasData) {
                _bilingualCache[cacheKey] = result;
                await _writePersistentCache(cacheKey, result);
                return result;
              }
            }
          }
        }
      }

      final fallback = await Future.wait([
        _fetchDrugInfoByLanguage(aiQueryName, 'en'),
        _fetchDrugInfoByLanguage(aiQueryName, 'ar'),
      ]);
      var result = BilingualDrugInfoResult(
        en: fallback[0],
        ar: fallback[1],
        correctedName: brandOverride,
      );

      if (!result.hasData) {
        final geminiResult = await _fetchBilingualFromGemini(aiQueryName);
        if (geminiResult != null && geminiResult.hasData) {
          result = BilingualDrugInfoResult(
            en: geminiResult.en,
            ar: geminiResult.ar,
            correctedName: brandOverride ?? geminiResult.correctedName,
          );
        } else if (geminiResult != null && geminiResult.suggestions.isNotEmpty) {
          collectedSuggestions = geminiResult.suggestions;
        }
      }

      // Last-resort fallback: if the AI returned nothing useful but we have
      // a local Egyptian-catalog hit, build a minimal DrugInfoResult from it
      // so the user still sees ingredient + category instead of a red error.
      if (!result.hasData && egyptianRecord != null) {
        final localInfo = _drugInfoFromEgyptianRecord(egyptianRecord);
        result = BilingualDrugInfoResult(
          en: localInfo,
          ar: localInfo,
          correctedName: brandOverride,
        );
      }

      if (!result.hasData && collectedSuggestions.isNotEmpty) {
        result = BilingualDrugInfoResult(suggestions: collectedSuggestions);
      }

      // Only cache successful lookups. Caching null/empty would prevent any
      // retry for the rest of the app session even if the AI would now succeed.
      if (result.isEmpty) return null;
      _bilingualCache[cacheKey] = result;
      // Only persist actual data — suggestions-only results aren't useful to keep.
      if (result.hasData) await _writePersistentCache(cacheKey, result);
      return result;
    } on Object catch (e) {
      debugPrint('AiDrugInfoService: fetchDrugInfoBilingual failed: $e');
      return null;
    }
  }

  Future<BilingualDrugInfoResult?> _readPersistentCache(String key) async {
    try {
      final rows = await AppDatabase()
          .customSelect(
            'SELECT payload FROM drug_info_cache WHERE normalized_name = ?',
            variables: [Variable.withString(key)],
          )
          .get();
      if (rows.isEmpty) return null;
      final payload = rows.first.read<String>('payload');
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final result = BilingualDrugInfoResult.fromJson(json);
      return result.isEmpty ? null : result;
    } on Object catch (e) {
      debugPrint('AiDrugInfoService: cache read failed: $e');
      return null;
    }
  }

  /// Build a minimal DrugInfoResult from a local Egyptian catalog record.
  /// Used as a last-resort fallback when both Groq and Gemini fail or return
  /// "unknown". The user still gets ingredient + category + manufacturer,
  /// which is enough for the interaction checker to work correctly.
  DrugInfoResult _drugInfoFromEgyptianRecord(EgyptianDrugRecord record) {
    final ingredients = record.activeIngredient?.split('+')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return DrugInfoResult(
      genericName: record.activeIngredient,
      activeIngredients: (ingredients == null || ingredients.isEmpty)
          ? null
          : ingredients,
      drugCategory: record.drugCategory,
      route: record.route,
      purpose: record.pharmacology != null && record.pharmacology!.length > 5
          ? record.pharmacology
          : null,
    );
  }

  /// True if two drug names are close enough that one could plausibly be a
  /// typo of the other. Rejects wildly different names (e.g. "كاتفلام" vs
  /// "كافيتامين") which the AI sometimes invents.
  bool _namesAreSimilar(String a, String b) {
    final na = DrugNameNormalizer.canonicalName(a).toLowerCase();
    final nb = DrugNameNormalizer.canonicalName(b).toLowerCase();
    if (na.isEmpty || nb.isEmpty) return true;
    if (na == nb) return true;
    if (na.contains(nb) || nb.contains(na)) return true;
    // Length diff > 40% → not a typo, a different drug.
    final lenDiff = (na.length - nb.length).abs();
    if (lenDiff > (na.length * 0.4).ceil()) return false;
    // First two chars must match (most pharmacy typos preserve start).
    if (na.length >= 2 && nb.length >= 2 && na.substring(0, 2) != nb.substring(0, 2)) {
      return false;
    }
    return true;
  }

  Future<void> _deletePersistentCache(String key) async {
    try {
      await AppDatabase().customStatement(
        'DELETE FROM drug_info_cache WHERE normalized_name = ?',
        [key],
      );
    } on Object catch (e) {
      debugPrint('AiDrugInfoService: cache delete failed: $e');
    }
  }

  Future<void> _writePersistentCache(
    String key,
    BilingualDrugInfoResult result,
  ) async {
    try {
      await AppDatabase().customStatement(
        'INSERT OR REPLACE INTO drug_info_cache '
        '(normalized_name, payload, cached_at) VALUES (?, ?, ?)',
        [key, jsonEncode(result.toJson()), DateTime.now().millisecondsSinceEpoch],
      );
    } on Object catch (e) {
      debugPrint('AiDrugInfoService: cache write failed: $e');
    }
  }

  Future<List<AiInteractionResult>> checkInteractions({
    required MedicationInteractionContext newDrug,
    required List<MedicationInteractionContext> existingDrugs,
  }) async {
    if (existingDrugs.isEmpty) return [];

    final newDesc = _describeMedication(newDrug);
    final existingDesc = existingDrugs.map(_describeMedication).join('\n- ');

    final prompt =
        '''
You are a clinical drug-interaction checker. Return ONLY a valid JSON array, no markdown, no prose.

SEVERITY SCALE — use exactly one:
- "minor": minimal clinical significance, no action needed
- "moderate": monitor closely, may need timing adjustment or dose review
- "major": avoid unless physician explicitly approves, high risk
- "severe": NEVER take together — life-threatening or absolute contraindication

RULES:
1. Flag ONLY clinically documented interactions with a named mechanism. If you are not certain, do NOT flag — better to miss a borderline case than invent one.
2. Use the provided dose/strength: only flag if the patient's actual dose crosses the documented risk threshold. Sub-threshold doses are NOT flagged.
3. Paracetamol (acetaminophen) ≤4 g/day: do NOT flag with NSAIDs, ibuprofen, antibiotics, antihypertensives, or other painkillers. Only flag paracetamol with: warfarin (chronic high cumulative dose), phenytoin, isoniazid, carbamazepine, or daily dose >4 g.
4. Paracetamol + ibuprofen at standard doses is SAFE — do NOT flag.
5. Do NOT confuse paracetamol with ibuprofen/aspirin. Bleeding/anticoagulant risks apply to NSAIDs and antiplatelets only.
6. Antifibrinolytics (tranexamic acid, aminocaproic acid) + NSAIDs or antiplatelets = "severe" thrombotic risk — always flag with neverCombine true.
7. Pro-coagulant + anticoagulant combinations = "severe" — always flag with neverCombine true.
8. Absorption-based interaction (one drug reduces absorption of the other) → set "hoursApart" to the required separation in hours.
9. Each pair must appear at MOST once. Do NOT emit (drug1,drug2) and (drug2,drug1) — pick one ordering.
10. If there are no real interactions, return [].

MUST-FLAG TEXTBOOK PAIRS — if both drugs are present in the patient list (by brand or active ingredient), you MUST flag them. These are not borderline:
- Calcium channel blocker (verapamil, diltiazem) + ANY beta-blocker (nebivolol, metoprolol, atenolol, bisoprolol, propranolol, carvedilol) → "severe" — bradycardia, AV block, heart failure risk.
- TWO antihypertensives from any classes → at least "moderate" — additive hypotension, monitor BP.
- TWO drugs lowering blood sugar (insulin + sulfonylurea, metformin + sulfonylurea, etc.) → "moderate" — hypoglycemia risk.
- TWO sedatives/CNS depressants (benzodiazepine + opioid, benzodiazepine + alcohol, opioid + sleep aid) → "severe" — respiratory depression.
- ACE inhibitor + ARB → "major" — kidney injury, hyperkalemia.
- Any anticoagulant + any antiplatelet → "major" — bleeding.
- Statin + macrolide (simvastatin/atorvastatin + clarithromycin/erythromycin) → "major" — rhabdomyolysis.
- SSRI + tramadol/MAOI → "major" — serotonin syndrome.
- Methotrexate + NSAID → "major" — methotrexate toxicity.
- Digoxin + verapamil/amiodarone → "major" — digoxin toxicity.
Treat these as DOCUMENTED — do not skip them under Rule 1 "if uncertain don't flag."

WRITING STYLE — VERY IMPORTANT:
- Tone is reassuring and educational, not alarming. The user sees this in their phone, not an emergency room.
- Always end the recommendation by directing the user to their doctor or pharmacist, in the same calm tone.
- Provide BOTH languages for description and recommendation:
  - "descriptionEn" + "recommendationEn": clear plain English, ≤ 30 words each.
  - "descriptionAr" + "recommendationAr": Egyptian colloquial Arabic (عامية مصرية) — NOT Modern Standard Arabic — ≤ 30 words each. End the Arabic recommendation with "استشير طبيبك أو الصيدلي".
- Avoid scary words like "deadly", "fatal", "خطر مميت". Say what could happen and how to handle it.

PATIENT NEW MEDICATION:
$newDesc

PATIENT EXISTING MEDICATIONS:
- $existingDesc

Return a JSON array (empty if no real interactions):
[{"drug1":"name","drug2":"name","severity":"minor|moderate|major|severe","neverCombine":false,"hoursApart":null,"descriptionEn":"calm explanation of what could happen at these doses","recommendationEn":"what to do, calm tone, ends by suggesting doctor/pharmacist","descriptionAr":"شرح بسيط بالعامية المصرية","recommendationAr":"نصيحة هادية بالعامية وتنتهي بـ استشير طبيبك أو الصيدلي","evidence":"ingredientA + ingredientB: mechanism"}]''';

    try {
      final response = await _tryGetResponse(prompt);
      if (response == null) return [];

      final jsonStr = _extractJsonArray(response);
      if (jsonStr == null) return [];

      final list = jsonDecode(jsonStr) as List;
      return list
          .map((e) => AiInteractionResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Object catch (e) {
      debugPrint('AiDrugInfoService: checkInteractions failed: $e');
      return [];
    }
  }

  String _describeMedication(MedicationInteractionContext ctx) {
    final parts = <String>[ctx.name];
    if (ctx.activeIngredients != null && ctx.activeIngredients!.isNotEmpty) {
      parts.add('ingredients: ${ctx.activeIngredients}');
    }
    if (ctx.drugCategory != null && ctx.drugCategory!.isNotEmpty) {
      parts.add('category: ${ctx.drugCategory}');
    }
    if (ctx.strength != null && ctx.strength!.isNotEmpty) {
      parts.add('strength: ${ctx.strength}');
    }
    if (ctx.dosePerTime != null && ctx.timesPerDay != null) {
      parts.add(
        'schedule: ${ctx.dosePerTime} x ${ctx.timesPerDay}/day',
      );
    }
    return parts.join(' | ');
  }

  Future<BilingualDrugInfoResult?> _fetchBilingualFromGemini(
    String drugName,
  ) async {
    try {
      _geminiService.initialize();
      final response = await _geminiService.sendMessage(
        _buildBilingualPrompt(drugName),
      );
      debugPrint('AiDrugInfoService: gemini bilingual raw for "$drugName" = $response');
      final json = _extractJson(response);
      if (json == null) return null;
      if (json.containsKey('unknown')) {
        final suggestions = _parseSuggestions(json['suggestions']);
        if (suggestions.isEmpty) return null;
        return BilingualDrugInfoResult(suggestions: suggestions);
      }
      final enJson = json['en'];
      final arJson = json['ar'];
      if (enJson is! Map<String, dynamic> && arJson is! Map<String, dynamic>) {
        return null;
      }
      final result = BilingualDrugInfoResult(
        en: enJson is Map<String, dynamic>
            ? DrugInfoResult.fromJson(enJson)
            : null,
        ar: arJson is Map<String, dynamic>
            ? DrugInfoResult.fromJson(arJson)
            : null,
        correctedName: json['correctedName'] as String?,
      );
      return result.hasData ? result : null;
    } on Object catch (e) {
      debugPrint('AiDrugInfoService: gemini fallback failed: $e');
      return null;
    }
  }

  List<String> _parseSuggestions(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .take(5)
        .toList();
  }

  Future<String?> _tryGetResponse(String prompt) async {
    try {
      _groqService.initialize();
      return await _sendRawGroq(prompt);
    } on Object {
      try {
        _geminiService.initialize();
        return await _geminiService.sendMessage(prompt);
      } on Object {
        return null;
      }
    }
  }

  String _buildBilingualPrompt(String drugName) {
    return '''
/no_think
Return ONLY valid JSON, no markdown, no explanation, no <think> block.

TYPO TOLERANCE — STRICT:
- Only correct typos when the difference is clearly 1-2 swapped/missing Latin letters (e.g. "panadool" → "panadol", "augmenten" → "augmentin").
- DO NOT "correct" an Arabic-script drug name to a different drug. If you don't recognize the exact Arabic spelling, return {"unknown": true, "suggestions": [...]} — never invent or substitute a drug you happen to know with a similar shape.
- DO NOT correct one real drug to another real drug. Cataflam is NOT Cavitamin. Panadol is NOT Pantoprazole. If unsure, return unknown.
- If the typo is ambiguous, return: {"unknown": true, "suggestions": ["closest1", "closest2", "closest3"]}
- "suggestions" must be 1-5 real drug names that the user might have meant. Use English names. If you cannot suggest any, omit the field.
Use simple everyday language — no medical jargon.
Arabic must be fully Egyptian colloquial (عامية مصرية) — not formal Modern Standard Arabic.
All boolean fields must be true or false — never a string.

SCRIPT RULES — STRICT:
- Arabic fields ("ar" object) must contain ONLY Arabic letters and digits. NO Chinese, NO Japanese, NO Korean, NO Cyrillic. If you must write a Latin word (drug brand), keep it minimal.
- English fields ("en" object) must contain ONLY Latin letters/digits. No Arabic, no Chinese, no Japanese, no Korean.
- If you cannot express something without using a forbidden script, omit that field (return null).

CRITICAL ACCURACY RULES:
- If you don't know a field with confidence, return null for that field. NEVER guess.
- If the drug name is unknown, ambiguous, or you would have to invent details, return exactly: {"unknown": true}
- "route" must be ONE single value (e.g. "oral"), not a list or slash-separated string.
- "contraindications" is a list — each item is one distinct group (pregnant women, liver patients, children under 12, etc.). Don't merge into one sentence.
- "requiresMonitoring" is null if no routine test/check is needed.

For drug "$drugName", return:
{
  "en": {
    "genericName": "string or null",
    "activeIngredients": ["item1", "item2"],
    "drugCategory": "plain-language category (e.g. Blood thinner, Antibiotic)",
    "purpose": "what it treats in simple words",
    "howToTake": "before/with/after meal + water advice",
    "bestTimeOfDay": "morning/evening/anytime + short reason why",
    "commonSideEffects": ["item1", "item2", "item3"],
    "drowsinessAffectsDriving": false,
    "drowsinessWarningNote": "write null if drowsinessAffectsDriving is false",
    "alcoholWarning": "avoid alcohol or safe with alcohol — one sentence",
    "contraindications": ["who must never take this drug"],
    "requiresMonitoring": "blood test or check needed, or null if none",
    "drugWarnings": ["specific warning 1", "specific warning 2"],
    "foodsToAvoid": ["item1", "item2"],
    "missedDoseAdvice": "what to do if dose is missed",
    "storageInstructions": "storage advice",
    "otcOrPrescription": "OTC or prescription only",
    "route": "oral/topical/injection/inhalation/etc"
  },
  "ar": {
    "genericName": "string or null",
    "activeIngredients": ["item1", "item2"],
    "drugCategory": "تصنيف بسيط بالعامية",
    "purpose": "بيتاخد لإيه بكلام بسيط",
    "howToTake": "قبل/مع/بعد الأكل + نصيحة المياه",
    "bestTimeOfDay": "أفضل وقت + سبب بسيط ليه",
    "commonSideEffects": ["عرض1", "عرض2", "عرض3"],
    "drowsinessAffectsDriving": false,
    "drowsinessWarningNote": "اكتب null لو drowsinessAffectsDriving بـ false",
    "alcoholWarning": "ابعد عن الكحول أو مفيش مشكلة — جملة واحدة",
    "contraindications": ["مين ميتاخدش منه خالص"],
    "requiresMonitoring": "تحليل أو متابعة لازمة، أو null لو مفيش",
    "drugWarnings": ["تحذير محدد 1", "تحذير محدد 2"],
    "foodsToAvoid": ["أكل1", "أكل2"],
    "missedDoseAdvice": "لو نسيت الجرعة تعمل إيه",
    "storageInstructions": "طريقة الحفظ",
    "otcOrPrescription": "بدون روشتة أو بروشتة بس",
    "route": "طريقة الاستخدام"
  }
}
If the drug is completely unknown, return: {"unknown": true}''';
  }

  String _buildSingleLanguagePrompt({
    required String drugName,
    required String language,
  }) {
    final target = language == 'ar'
        ? 'Egyptian colloquial Arabic (عامية مصرية) — not Modern Standard Arabic'
        : 'English';
    return '''
/no_think
Return ONLY valid JSON, no markdown, no explanation, no <think> block.
Use simple everyday language (no medical jargon).
Answer in $target.

TYPO TOLERANCE:
- If the drug name has 1-2 letter typos and you can confidently identify the intended drug, use the corrected name and add a "correctedName" field with the corrected spelling.
- If ambiguous, return: {"unknown": true, "suggestions": ["name1", "name2"]} (1-5 real English drug names that the user might have meant). Omit "suggestions" if you cannot suggest any.

CRITICAL ACCURACY RULES:
- If you don't know a field with confidence, return null for that field. NEVER guess.
- If the drug is unknown or you would have to invent details, return exactly: {"unknown": true}
- "route" must be ONE single value (e.g. "oral"), not a list.
- "contraindications" is a list — each item is one distinct group.
- "requiresMonitoring" is null if no routine test/check is needed.
- All boolean fields must be true or false — never a string.

For drug "$drugName", return:
{
  "genericName": "string or null",
  "activeIngredients": ["item1", "item2"],
  "drugCategory": "plain-language category",
  "purpose": "what it treats in simple words",
  "howToTake": "before/with/after meal + water advice",
  "bestTimeOfDay": "morning/night/anytime + short reason",
  "commonSideEffects": ["item1", "item2", "item3"],
  "drowsinessAffectsDriving": false,
  "drowsinessWarningNote": "null if drowsinessAffectsDriving is false",
  "alcoholWarning": "avoid alcohol or safe with alcohol — one sentence",
  "contraindications": ["who must never take this drug"],
  "requiresMonitoring": "blood test or check needed, or null if none",
  "drugWarnings": ["item1", "item2"],
  "foodsToAvoid": ["item1", "item2"],
  "missedDoseAdvice": "what to do if dose is missed",
  "storageInstructions": "storage advice",
  "otcOrPrescription": "OTC or prescription only",
  "route": "oral/topical/injection/inhalation/etc"
}
If unknown, return: {"unknown": true}''';
  }

  Future<DrugInfoResult?> _fetchDrugInfoByLanguage(
    String drugName,
    String language,
  ) async {
    final response = await _tryGetResponse(
      _buildSingleLanguagePrompt(drugName: drugName, language: language),
    );
    debugPrint('AiDrugInfoService: $language raw response for "$drugName" = $response');
    if (response == null) return null;
    final json = _extractJson(response);
    debugPrint('AiDrugInfoService: $language parsed json keys = ${json?.keys.toList()}');
    if (json == null || json.containsKey('unknown')) return null;
    final result = DrugInfoResult.fromJson(json);
    return result.isEmpty ? null : result;
  }

  Future<String> _sendRawGroq(String prompt) async {
    return _groqService.sendRawCompletion(prompt);
  }

  Map<String, dynamic>? _extractJson(String response) {
    try {
      final start = response.indexOf('{');
      final end = response.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) return null;
      return jsonDecode(response.substring(start, end + 1))
          as Map<String, dynamic>;
    } on Object {
      return null;
    }
  }

  String? _extractJsonArray(String response) {
    try {
      final start = response.indexOf('[');
      final end = response.lastIndexOf(']');
      if (start == -1 || end == -1 || end <= start) return null;
      return response.substring(start, end + 1);
    } on Object {
      return null;
    }
  }
}
