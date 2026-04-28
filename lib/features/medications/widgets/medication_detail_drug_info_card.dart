import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/database/repositories/medication_repository.dart';
import 'package:med_assist/features/medications/models/display_drug_info.dart';
import 'package:med_assist/features/medications/widgets/drug_info_content_card.dart';
import 'package:med_assist/features/medications/widgets/drug_info_state_cards.dart';
import 'package:med_assist/services/ai/ai_drug_info_service.dart';
import 'package:med_assist/services/health/drug_info_extras_service.dart';

/// Shows AI-powered drug information for a medication.
/// Auto-fetches from AI on first open if no data is in the DB yet.
class MedicationDetailDrugInfoCard extends ConsumerStatefulWidget {
  const MedicationDetailDrugInfoCard({
    required this.medication,
    super.key,
  });

  final Medication medication;

  @override
  ConsumerState<MedicationDetailDrugInfoCard> createState() =>
      _MedicationDetailDrugInfoCardState();
}

class _MedicationDetailDrugInfoCardState
    extends ConsumerState<MedicationDetailDrugInfoCard> {
  List<MedicationDrugInfoData>? _dbEntries;
  List<DrugInfoExtras> _extras = const [];
  bool _loading = false;
  bool _fetchFailed = false;
  List<String> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadFromDb());
  }

  Future<void> _loadFromDb() async {
    final db = ref.read(appDatabaseProvider);
    final entries = await db.getMedicationDrugInfoAllLanguages(
      widget.medication.id,
    );
    final extras = await DrugInfoExtrasService(db).forMedication(
      widget.medication.id,
    );
    if (!mounted) return;

    final info = DisplayDrugInfo.fromSources(
      medication: widget.medication,
      requestedLanguage: 'en',
      localizedEntries: entries,
      extras: extras,
    );

    if (info.isEmpty) {
      await _fetchFromAi();
    } else {
      setState(() {
        _dbEntries = entries;
        _extras = extras;
      });
    }
  }

  Future<void> _fetchFromAi({
    String? overrideName,
    bool forceRefresh = false,
  }) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _fetchFailed = false;
      _suggestions = const [];
    });

    final lookupName = overrideName ?? widget.medication.medicineName;

    try {
      final bilingual = await AiDrugInfoService().fetchDrugInfoBilingual(
        lookupName,
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;

      if (bilingual == null) {
        setState(() {
          _loading = false;
          _fetchFailed = true;
        });
        return;
      }

      if (!bilingual.hasData) {
        setState(() {
          _loading = false;
          _fetchFailed = true;
          _suggestions = bilingual.suggestions;
        });
        return;
      }

      final repo = ref.read(medicationRepositoryProvider);
      final db = ref.read(appDatabaseProvider);
      final extrasService = DrugInfoExtrasService(db);
      await _saveLanguage(repo, bilingual.en, 'en', extrasService);
      await _saveLanguage(repo, bilingual.ar, 'ar', extrasService);

      // Critical: also push activeIngredients/drugCategory/genericName into the
      // medication row itself so future interaction checks can match on them.
      // (`getAllMedications()` reads from the medication table, not localized
      //  drug-info tables.)
      final preferred = bilingual.en ?? bilingual.ar;
      if (preferred != null && !preferred.isEmpty) {
        final updated = widget.medication.copyWith(
          genericName: drift.Value(
            preferred.genericName ?? widget.medication.genericName,
          ),
          activeIngredients: drift.Value(
            preferred.activeIngredients?.join(', ') ??
                widget.medication.activeIngredients,
          ),
          drugCategory: drift.Value(
            preferred.drugCategory ?? widget.medication.drugCategory,
          ),
          updatedAt: DateTime.now(),
        );
        await db.updateMedication(updated);
      }

      if (!mounted) return;
      final refreshed = await db.getMedicationDrugInfoAllLanguages(
        widget.medication.id,
      );
      final refreshedExtras = await extrasService.forMedication(
        widget.medication.id,
      );
      setState(() {
        _dbEntries = refreshed;
        _extras = refreshedExtras;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _fetchFailed = true;
      });
    }
  }

  Future<void> _saveLanguage(
    MedicationRepository repo,
    DrugInfoResult? info,
    String language,
    DrugInfoExtrasService extrasService,
  ) async {
    if (info == null || info.isEmpty) return;
    await repo.upsertLocalizedDrugInfo(
      medicationId: widget.medication.id,
      language: language,
      genericName: info.genericName,
      activeIngredients: info.activeIngredients?.join(', '),
      drugCategory: info.drugCategory,
      purpose: info.purpose,
      howToTake: info.howToTake,
      bestTimeOfDay: info.bestTimeOfDay,
      drowsinessAffectsDriving: info.drowsinessAffectsDriving,
      drowsinessWarning: info.drowsinessWarning,
      foodsToAvoid: info.foodsToAvoid?.join(', '),
      missedDoseAdvice: info.missedDoseAdvice,
      storageInstructions: info.storageInstructions,
      sideEffects: info.commonSideEffects?.join(', '),
      warnings: info.warnings?.join(', '),
      route: info.route,
    );
    await extrasService.upsert(
      medicationId: widget.medication.id,
      language: language,
      alcoholWarning: info.alcoholWarning,
      contraindications: info.contraindications?.join(', '),
      requiresMonitoring: info.requiresMonitoring,
      otcOrPrescription: info.otcOrPrescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const DrugInfoLoadingCard();
    if (_fetchFailed) {
      return DrugInfoErrorCard(
        onRetry: _fetchFromAi,
        suggestions: _suggestions,
        onSuggestionTap: (name) => _fetchFromAi(overrideName: name),
      );
    }

    final requestedLanguage = Localizations.localeOf(context).languageCode;
    final info = DisplayDrugInfo.fromSources(
      medication: widget.medication,
      requestedLanguage: requestedLanguage,
      localizedEntries: _dbEntries ?? [],
      extras: _extras,
    );

    if (info.isEmpty) return const SizedBox.shrink();

    return DrugInfoContentCard(
      info: info,
      onRefresh: () => _fetchFromAi(forceRefresh: true),
    );
  }
}
