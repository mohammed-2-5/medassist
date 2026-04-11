import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/current_step_provider.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/screens/steps/step1_type_info.dart';
import 'package:med_assist/features/add_medication/screens/steps/step2_schedule.dart';
import 'package:med_assist/features/add_medication/screens/steps/step3_stock.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Add Medication Screen - 3-step wizard
class AddMedicationScreen extends ConsumerWidget {
  const AddMedicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(currentStepProvider);
    final formData = ref.watch(medicationFormProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          // Progress indicator
          _buildProgressIndicator(context, currentStep, theme, colorScheme),

          // Step content
          Expanded(
            child: IndexedStack(
              index: currentStep,
              children: const [
                Step1TypeInfo(),
                Step2Schedule(),
                Step3Stock(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildNavigationFAB(
        context,
        ref,
        currentStep,
        formData,
        colorScheme,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    int currentStep,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          _buildStepCircle(0, currentStep, l10n.type, colorScheme, theme),
          _buildConnector(currentStep >= 1, colorScheme),
          _buildStepCircle(1, currentStep, l10n.schedule, colorScheme, theme),
          _buildConnector(currentStep >= 2, colorScheme),
          _buildStepCircle(2, currentStep, l10n.stock, colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildStepCircle(
    int step,
    int currentStep,
    String label,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final isActive = step == currentStep;
    final isCompleted = step < currentStep;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? colorScheme.secondary
                  : isActive
                      ? colorScheme.primary
                      : colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? colorScheme.primary
                    : isCompleted
                        ? colorScheme.secondary
                        : colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: colorScheme.onSecondary,
                      size: 20,
                    )
                  : Text(
                      '${step + 1}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isActive
                            ? colorScheme.onPrimary
                            : colorScheme.primary.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.bold : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(bool isActive, ColorScheme colorScheme) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 2,
        margin: const EdgeInsets.only(bottom: 32),
        color: isActive ? colorScheme.secondary : colorScheme.outlineVariant,
      ),
    );
  }

  Widget _buildNavigationFAB(
    BuildContext context,
    WidgetRef ref,
    int currentStep,
    MedicationFormData formData,
    ColorScheme colorScheme,
  ) {
    final canProceed = _canProceedToNextStep(currentStep, formData);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Back button
          if (currentStep > 0)
            FloatingActionButton(
              onPressed: () => _previousStep(ref),
              heroTag: 'back',
              child: const Icon(Icons.arrow_back),
            ),

          const Spacer(),

          // Next/Finish button
          FloatingActionButton.extended(
            onPressed: canProceed
                ? () => _nextStep(context, ref, currentStep, formData)
                : null,
            heroTag: 'next',
            backgroundColor: canProceed
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            label: Text(
              currentStep < 2 ? AppLocalizations.of(context)!.next : AppLocalizations.of(context)!.finish,
              style: TextStyle(
                color: canProceed
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: Icon(
              currentStep < 2 ? Icons.arrow_forward : Icons.check,
              color: canProceed
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedToNextStep(int step, MedicationFormData formData) {
    switch (step) {
      case 0:
        return formData.isStep1Valid;
      case 1:
        return formData.isStep2Valid;
      case 2:
        return formData.isStep3Valid;
      default:
        return false;
    }
  }

  void _previousStep(WidgetRef ref) {
    ref.read(currentStepProvider.notifier).previousStep();
  }

  Future<void> _nextStep(
    BuildContext context,
    WidgetRef ref,
    int currentStep,
    dynamic formData,
  ) async {
    if (currentStep < 2) {
      // Move to next step
      ref.read(currentStepProvider.notifier).state = currentStep + 1;
    } else {
      // Finish and save
      await _saveMedication(context, ref);
    }
  }

  Future<void> _saveMedication(BuildContext context, WidgetRef ref) async {
    // Show loading (don't await — showDialog future completes on dismiss)
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    ));

    // Save medication
    final success =
        await ref.read(medicationFormProvider.notifier).saveMedication();

    if (context.mounted) {
      Navigator.pop(context); // Close loading
      final l10n = AppLocalizations.of(context)!;

      if (success) {
        // Clear any saved draft
        await ref.read(medicationFormProvider.notifier).clearDraft();

        // Refresh all medication-related providers
        ProviderRefreshUtils.refreshAllMedicationProviders(ref);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.medicineAddedSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Reset form and go back
        ref.read(medicationFormProvider.notifier).reset();
        ref.read(currentStepProvider.notifier).state = 0;
        context.pop();
      } else {
        // Show error
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
      // Go to previous step
      _previousStep(ref);
    } else {
      // Show confirmation dialog
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
                Navigator.pop(context); // Close dialog
                context.pop(); // Close screen
              },
              child: Text(AppLocalizations.of(context)!.discard),
            ),
          ],
        ),
      );
    }
  }
}
