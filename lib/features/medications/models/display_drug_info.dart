import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/health/drug_info_extras_service.dart';

/// View-model built from localized DB entries + base medication fields.
/// Resolved in preferred language, falling back to English then base data.
class DisplayDrugInfo {
  const DisplayDrugInfo({
    this.genericName,
    this.activeIngredients,
    this.drugCategory,
    this.purpose,
    this.howToTake,
    this.bestTimeOfDay,
    this.sideEffects,
    this.drowsinessAffectsDriving = false,
    this.drowsinessWarning,
    this.foodsToAvoid,
    this.warnings,
    this.missedDoseAdvice,
    this.storageInstructions,
    this.route,
    this.alcoholWarning,
    this.contraindications,
    this.requiresMonitoring,
    this.otcOrPrescription,
  });

  factory DisplayDrugInfo.fromSources({
    required Medication medication,
    required String requestedLanguage,
    required List<MedicationDrugInfoData> localizedEntries,
    List<DrugInfoExtras> extras = const [],
  }) {
    final normalizedLanguage = requestedLanguage.toLowerCase().startsWith('ar')
        ? 'ar'
        : 'en';
    final preferred = _pickByLanguage(
      localizedEntries,
      normalizedLanguage,
      (e) => e.language,
    );
    final english = _pickByLanguage(
      localizedEntries,
      'en',
      (e) => e.language,
    );
    final preferredExtras = _pickByLanguage(
      extras,
      normalizedLanguage,
      (e) => e.language,
    );
    final englishExtras = _pickByLanguage(extras, 'en', (e) => e.language);

    String? resolveExtra(String? Function(DrugInfoExtras e) pick) {
      final p = preferredExtras == null ? null : pick(preferredExtras);
      final e = englishExtras == null ? null : pick(englishExtras);
      return _clean(p ?? e);
    }

    String? resolve({
      required String? Function(MedicationDrugInfoData info) fromLocalized,
      String? baseValue,
    }) {
      final preferredValue = preferred == null
          ? null
          : fromLocalized(preferred);
      final englishValue = english == null ? null : fromLocalized(english);
      return _clean(preferredValue ?? englishValue ?? baseValue);
    }

    bool resolveBool({
      required bool Function(MedicationDrugInfoData info) fromLocalized,
      bool baseValue = false,
    }) {
      if (preferred != null) return fromLocalized(preferred);
      if (english != null) return fromLocalized(english);
      return baseValue;
    }

    return DisplayDrugInfo(
      genericName: resolve(
        fromLocalized: (i) => i.genericName,
        baseValue: medication.genericName,
      ),
      activeIngredients: resolve(
        fromLocalized: (i) => i.activeIngredients,
        baseValue: medication.activeIngredients,
      ),
      drugCategory: resolve(
        fromLocalized: (i) => i.drugCategory,
        baseValue: medication.drugCategory,
      ),
      purpose: resolve(
        fromLocalized: (i) => i.purpose,
        baseValue: medication.purpose,
      ),
      howToTake: resolve(fromLocalized: (i) => i.howToTake),
      bestTimeOfDay: resolve(fromLocalized: (i) => i.bestTimeOfDay),
      sideEffects: resolve(
        fromLocalized: (i) => i.sideEffects,
        baseValue: medication.sideEffects,
      ),
      drowsinessAffectsDriving: resolveBool(
        fromLocalized: (i) => i.drowsinessAffectsDriving,
      ),
      drowsinessWarning: resolve(fromLocalized: (i) => i.drowsinessWarning),
      foodsToAvoid: resolve(fromLocalized: (i) => i.foodsToAvoid),
      warnings: resolve(
        fromLocalized: (i) => i.warnings,
        baseValue: medication.warnings,
      ),
      missedDoseAdvice: resolve(fromLocalized: (i) => i.missedDoseAdvice),
      storageInstructions: resolve(fromLocalized: (i) => i.storageInstructions),
      route: resolve(
        fromLocalized: (i) => i.route,
        baseValue: medication.route,
      ),
      alcoholWarning: resolveExtra((e) => e.alcoholWarning),
      contraindications: resolveExtra((e) => e.contraindications),
      requiresMonitoring: resolveExtra((e) => e.requiresMonitoring),
      otcOrPrescription: resolveExtra((e) => e.otcOrPrescription),
    );
  }

  final String? genericName;
  final String? activeIngredients;
  final String? drugCategory;
  final String? purpose;
  final String? howToTake;
  final String? bestTimeOfDay;
  final String? sideEffects;
  final bool drowsinessAffectsDriving;
  final String? drowsinessWarning;
  final String? foodsToAvoid;
  final String? warnings;
  final String? missedDoseAdvice;
  final String? storageInstructions;
  final String? route;
  final String? alcoholWarning;
  final String? contraindications;
  final String? requiresMonitoring;
  final String? otcOrPrescription;

  bool get hasBasics =>
      genericName != null ||
      activeIngredients != null ||
      drugCategory != null ||
      purpose != null ||
      route != null ||
      otcOrPrescription != null;

  bool get hasDrowsinessWarning =>
      drowsinessAffectsDriving || drowsinessWarning != null;

  bool get hasWatchOut =>
      warnings != null ||
      hasDrowsinessWarning ||
      foodsToAvoid != null ||
      alcoholWarning != null ||
      contraindications != null;

  bool get isEmpty =>
      !hasBasics &&
      howToTake == null &&
      bestTimeOfDay == null &&
      sideEffects == null &&
      !hasWatchOut &&
      missedDoseAdvice == null &&
      storageInstructions == null &&
      requiresMonitoring == null;

  String drowsinessMessage(AppLocalizations l10n) {
    final note = drowsinessWarning;
    if (drowsinessAffectsDriving && note != null) {
      return '${l10n.mayCauseDrowsiness} $note';
    }
    if (drowsinessAffectsDriving) return l10n.mayCauseDrowsiness;
    return note ?? '';
  }

  static String? _clean(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static T? _pickByLanguage<T>(
    List<T> entries,
    String language,
    String Function(T) lang,
  ) {
    for (final entry in entries) {
      if (lang(entry) == language) return entry;
    }
    return null;
  }
}
