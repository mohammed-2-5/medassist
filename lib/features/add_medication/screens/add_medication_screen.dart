import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/database/repositories/medication_repository.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/current_step_provider.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/screens/steps/step1_type_info.dart';
import 'package:med_assist/features/add_medication/screens/steps/step2_schedule.dart';
import 'package:med_assist/features/add_medication/screens/steps/step3_stock.dart';
import 'package:med_assist/features/add_medication/widgets/add_medication_navigation_fab.dart';
import 'package:med_assist/features/add_medication/widgets/add_medication_progress_indicator.dart';
import 'package:med_assist/features/add_medication/widgets/interaction_check_dialog.dart';
import 'package:med_assist/features/add_medication/widgets/medication_saved_dialog.dart';
import 'package:med_assist/features/medications/providers/drug_interaction_providers.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/ai/ai_drug_info_service.dart';
import 'package:med_assist/services/health/drug_info_extras_service.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(currentStepProvider);
    final formData = ref.watch(medicationFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addMedicineTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isSaving ? null : () => _handleBack(context, ref),
        ),
        actions: [
          if (currentStep < 2)
            TextButton(
              onPressed: _isSaving ? null : () => _saveDraft(context, ref),
              child: Text(AppLocalizations.of(context)!.saveDraft),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              AddMedicationProgressIndicator(currentStep: currentStep),
              Expanded(
                child: switch (currentStep) {
                  0 => const Step1TypeInfo(),
                  1 => const Step2Schedule(),
                  2 => const Step3Stock(),
                  _ => const SizedBox.shrink(),
                },
              ),
            ],
          ),
          if (_isSaving)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.savingMedicine,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: AddMedicationNavigationFab(
        currentStep: currentStep,
        formData: formData,
        isSaving: _isSaving,
        onBack: () => _previousStep(ref),
        onNext: _isSaving ? null : () => _nextStep(context, ref, currentStep),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _previousStep(WidgetRef ref) {
    ref.read(currentStepProvider.notifier).previousStep();
  }

  Future<void> _nextStep(
    BuildContext context,
    WidgetRef ref,
    int currentStep,
  ) async {
    if (currentStep == 0) {
      ref.read(currentStepProvider.notifier).setStep(1);
      _fetchDrugInfoInBackground(context, ref);
    } else if (currentStep < 2) {
      ref.read(currentStepProvider.notifier).setStep(currentStep + 1);
    } else {
      await _saveMedication(context, ref);
    }
  }

  void _fetchDrugInfoInBackground(BuildContext context, WidgetRef ref) {
    final formData = ref.read(medicationFormProvider);
    final name = formData.medicineName?.trim() ?? '';
    if (name.isEmpty || formData.genericName != null) return;
    final languageCode = Localizations.localeOf(context).languageCode;

    unawaited(
      AiDrugInfoService().fetchDrugInfoBilingual(name).then((bilingualResult) {
        if (!mounted) return;
        // AI didn't recognize the name but offered alternatives — let the user
        // pick one (handles typos / wrong spellings).
        if (bilingualResult != null &&
            !bilingualResult.hasData &&
            bilingualResult.suggestions.isNotEmpty) {
          unawaited(
            _showDidYouMeanDialog(context, bilingualResult.suggestions),
          );
          return;
        }
        final result = bilingualResult?.forLanguage(languageCode);
        if (result == null || result.isEmpty) return;
        ref
            .read(medicationFormProvider.notifier)
            .setDrugInfo(
              genericName: result.genericName,
              activeIngredients: result.activeIngredients?.join(', '),
              drugCategory: result.drugCategory,
              purpose: result.purpose,
              sideEffects: result.commonSideEffects?.join(', '),
              drugWarnings: result.warnings?.join(', '),
              drugRoute: result.route,
            );
        ref
            .read(medicationFormProvider.notifier)
            .applyMealTimingSuggestion(result.inferMealTiming());
      }),
    );
  }

  Future<void> _showDidYouMeanDialog(
    BuildContext context,
    List<String> suggestions,
  ) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.drugInfoDidYouMean),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final name in suggestions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, name),
                  child: Text(name),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    if (!mounted || picked == null || picked.isEmpty) return;
    ref.read(medicationFormProvider.notifier).setMedicineName(picked);
    _fetchDrugInfoInBackground(context, ref);
  }

  Future<void> _saveMedication(BuildContext context, WidgetRef ref) async {
    // Re-entry guard: blocks duplicate inserts when the user double-taps the
    // Finish button while the AI interaction-check is still running.
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final formData = ref.read(medicationFormProvider);
      final medName = formData.medicineName ?? '';
      final localeLanguageCode = Localizations.localeOf(context).languageCode;

      if (!formData.isEdit && medName.trim().isNotEmpty) {
        final duplicate = await ref
            .read(medicationRepositoryProvider)
            .findDuplicate(
              name: medName,
              strength: formData.strength,
              unit: formData.unit,
            );
        if (duplicate != null) {
          if (!context.mounted) return;
          setState(() => _isSaving = false);
          final shouldEdit = await _showDuplicateDialog(context);
          if (!context.mounted) return;
          if (shouldEdit) {
            context.pushReplacement('/medication/${duplicate.id}/edit');
          }
          return;
        }
      }

      var hasInteractions = false;
      var foundWarnings = <InteractionWarning>[];

      if (medName.isNotEmpty) {
        try {
          final params = NewMedicationCheckParams(
            name: medName,
            activeIngredients: formData.activeIngredients,
            drugCategory: formData.drugCategory,
            strength: formData.strength,
            dosePerTime: formData.dosePerTime,
            timesPerDay: formData.timesPerDay,
            reminderMinutes: formData.reminderTimes
                .map((r) => r.time.hour * 60 + r.time.minute)
                .toList(),
          );
          foundWarnings = await ref.read(
            checkNewMedicationProvider(params).future,
          );
          if (foundWarnings.isNotEmpty && context.mounted) {
            hasInteractions = true;
            // Hide the saving overlay while the user reads the warnings sheet,
            // then re-enable it for the actual save.
            setState(() => _isSaving = false);
            final proceed = await InteractionCheckDialog.show(
              context,
              foundWarnings,
            );
            if (!proceed || !context.mounted) return;
            setState(() => _isSaving = true);
          }
        } on Object {
          // Non-blocking
        }
      }

      if (!context.mounted) return;

      final savedMedicationId = await ref
          .read(medicationFormProvider.notifier)
          .saveMedicationAndGetId();
      final success = savedMedicationId != null;

      if (savedMedicationId != null) {
        await _persistBilingualDrugInfo(
          ref: ref,
          medicationId: savedMedicationId,
          formData: formData,
          localeLanguageCode: localeLanguageCode,
        );
        if (foundWarnings.isNotEmpty) {
          try {
            await ref
                .read(medicationRepositoryProvider)
                .persistAcceptedInteractions(
                  newMedicationId: savedMedicationId,
                  warnings: foundWarnings,
                );
          } catch (e) {
            // non-blocking; warnings are advisory only
          }
        }
      }

      if (!context.mounted) return;
      // Close the saving overlay before showing the success/failure dialog.
      setState(() => _isSaving = false);
      final l10n = AppLocalizations.of(context)!;

      if (success) {
        await ref.read(medicationFormProvider.notifier).clearDraft();
        ProviderRefreshUtils.refreshAllMedicationProviders(ref);

        if (context.mounted) {
          await MedicationSavedDialog.show(
            context,
            hasDrugInfo:
                formData.purpose != null || formData.sideEffects != null,
            hasInteractions: hasInteractions,
            interactionCount: foundWarnings.length,
          );
        }

        if (context.mounted) {
          ref.read(medicationFormProvider.notifier).reset();
          ref.read(currentStepProvider.notifier).reset();
          context.pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToSaveMedicine),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted && _isSaving) setState(() => _isSaving = false);
    }
  }

  Future<void> _persistBilingualDrugInfo({
    required WidgetRef ref,
    required int medicationId,
    required MedicationFormData formData,
    required String localeLanguageCode,
  }) async {
    final medicationName = formData.medicineName?.trim() ?? '';
    if (medicationName.isEmpty) return;

    final repository = ref.read(medicationRepositoryProvider);
    final extrasService = DrugInfoExtrasService(ref.read(appDatabaseProvider));
    final bilingual = await AiDrugInfoService().fetchDrugInfoBilingual(
      medicationName,
    );

    if (bilingual == null || bilingual.isEmpty) {
      final fallback = DrugInfoResult(
        genericName: formData.genericName,
        activeIngredients: _splitListOrNull(formData.activeIngredients),
        drugCategory: formData.drugCategory,
        purpose: formData.purpose,
        commonSideEffects: _splitListOrNull(formData.sideEffects),
        warnings: _splitListOrNull(formData.drugWarnings),
        route: formData.drugRoute,
      );
      if (fallback.isEmpty) return;
      await _persistLocalizedDrugInfo(
        repository: repository,
        medicationId: medicationId,
        language: localeLanguageCode,
        info: fallback,
        extrasService: extrasService,
      );
      return;
    }

    final enInfo = bilingual.en;
    if (enInfo != null && !enInfo.isEmpty) {
      await _persistLocalizedDrugInfo(
        repository: repository,
        medicationId: medicationId,
        language: 'en',
        info: enInfo,
        extrasService: extrasService,
      );
    }

    final arInfo = bilingual.ar;
    if (arInfo != null && !arInfo.isEmpty) {
      await _persistLocalizedDrugInfo(
        repository: repository,
        medicationId: medicationId,
        language: 'ar',
        info: arInfo,
        extrasService: extrasService,
      );
    }
  }

  Future<void> _persistLocalizedDrugInfo({
    required MedicationRepository repository,
    required int medicationId,
    required String language,
    required DrugInfoResult info,
    DrugInfoExtrasService? extrasService,
  }) async {
    await repository.upsertLocalizedDrugInfo(
      medicationId: medicationId,
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
    final hasExtras = info.alcoholWarning != null ||
        (info.contraindications?.isNotEmpty ?? false) ||
        info.requiresMonitoring != null ||
        info.otcOrPrescription != null;
    if (hasExtras && extrasService != null) {
      await extrasService.upsert(
        medicationId: medicationId,
        language: language,
        alcoholWarning: info.alcoholWarning,
        contraindications: info.contraindications?.join(', '),
        requiresMonitoring: info.requiresMonitoring,
        otcOrPrescription: info.otcOrPrescription,
      );
    }
  }

  List<String>? _splitListOrNull(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    final parts = raw
        .split(RegExp(r'[,،؛\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts;
  }

  Future<bool> _showDuplicateDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.duplicateMedicineTitle),
        content: Text(l10n.duplicateMedicineMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.editExistingMedicine),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveDraft(BuildContext context, WidgetRef ref) async {
    await ref.read(medicationFormProvider.notifier).saveDraft();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.draftSaved)),
      );
    }
  }

  void _handleBack(BuildContext context, WidgetRef ref) {
    final currentStep = ref.read(currentStepProvider);

    if (currentStep > 0) {
      _previousStep(ref);
    } else {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.discardChanges),
            content: Text(
              AppLocalizations.of(context)!.discardChangesConfirmation,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () {
                  ref.read(medicationFormProvider.notifier).reset();
                  ref.read(currentStepProvider.notifier).reset();
                  Navigator.pop(context);
                  context.pop();
                },
                child: Text(AppLocalizations.of(context)!.discard),
              ),
            ],
          ),
        ),
      );
    }
  }
}
