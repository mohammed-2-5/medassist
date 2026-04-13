import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
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
import 'package:med_assist/services/health/drug_interaction_service.dart';

class AddMedicationScreen extends ConsumerWidget {
  const AddMedicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(currentStepProvider);
    final formData = ref.watch(medicationFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addMedicineTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleBack(context, ref),
        ),
        actions: [
          if (currentStep < 2)
            TextButton(
              onPressed: () => _saveDraft(context, ref),
              child: Text(AppLocalizations.of(context)!.saveDraft),
            ),
        ],
      ),
      body: Column(
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
      floatingActionButton: AddMedicationNavigationFab(
        currentStep: currentStep,
        formData: formData,
        onBack: () => _previousStep(ref),
        onNext: () => _nextStep(context, ref, currentStep),
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
      ref.read(currentStepProvider.notifier).state = 1;
      _fetchDrugInfoInBackground(ref);
    } else if (currentStep < 2) {
      ref.read(currentStepProvider.notifier).state = currentStep + 1;
    } else {
      await _saveMedication(context, ref);
    }
  }

  void _fetchDrugInfoInBackground(WidgetRef ref) {
    final formData = ref.read(medicationFormProvider);
    final name = formData.medicineName?.trim() ?? '';
    if (name.isEmpty || formData.genericName != null) return;

    unawaited(
      AiDrugInfoService().fetchDrugInfo(name).then((result) {
        if (result == null || result.isEmpty) return;
        ref.read(medicationFormProvider.notifier).setDrugInfo(
              genericName: result.genericName,
              activeIngredients: result.activeIngredients?.join(', '),
              drugCategory: result.drugCategory,
              purpose: result.purpose,
              sideEffects: result.commonSideEffects?.join(', '),
              drugWarnings: result.warnings?.join(', '),
              drugRoute: result.route,
            );
      }),
    );
  }

  Future<void> _saveMedication(BuildContext context, WidgetRef ref) async {
    final formData = ref.read(medicationFormProvider);
    final medName = formData.medicineName ?? '';

    var hasInteractions = false;
    List<InteractionWarning> foundWarnings = [];

    if (medName.isNotEmpty) {
      try {
        final params = NewMedicationCheckParams(
          name: medName,
          activeIngredients: formData.activeIngredients,
          drugCategory: formData.drugCategory,
        );
        foundWarnings = await ref.read(
          checkNewMedicationProvider(params).future,
        );
        if (foundWarnings.isNotEmpty && context.mounted) {
          hasInteractions = true;
          final proceed =
              await InteractionCheckDialog.show(context, foundWarnings);
          if (!proceed || !context.mounted) return;
        }
      } catch (_) {
        // Non-blocking
      }
    }

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    ));

    final success =
        await ref.read(medicationFormProvider.notifier).saveMedication();

    if (context.mounted) {
      Navigator.pop(context); // Close loading
      final l10n = AppLocalizations.of(context)!;

      if (success) {
        await ref.read(medicationFormProvider.notifier).clearDraft();
        ProviderRefreshUtils.refreshAllMedicationProviders(ref);

        if (context.mounted) {
          await MedicationSavedDialog.show(
            context,
            hasDrugInfo: formData.purpose != null ||
                formData.sideEffects != null,
            hasInteractions: hasInteractions,
            interactionCount: foundWarnings.length,
          );
        }

        if (context.mounted) {
          ref.read(medicationFormProvider.notifier).reset();
          ref.read(currentStepProvider.notifier).state = 0;
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
    }
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
      showDialog(
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
                ref.read(currentStepProvider.notifier).state = 0;
                Navigator.pop(context);
                context.pop();
              },
              child: Text(AppLocalizations.of(context)!.discard),
            ),
          ],
        ),
      );
    }
  }
}
