import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/current_step_provider.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/medications/utils/medication_edit_actions.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Bottom navigation buttons for the medication edit/add wizard.
///
/// Watches step and form state internally — parent only passes [medicationId].
class MedicationEditNavButtons extends ConsumerWidget {
  const MedicationEditNavButtons({required this.medicationId, super.key});

  final int medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final currentStep = ref.watch(currentStepProvider);
    final formData = ref.watch(medicationFormProvider);
    final canProceed = _canProceed(currentStep, formData);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      ref.read(currentStepProvider.notifier).previousStep(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(l10n.back),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton(
                onPressed: canProceed
                    ? () => _onNextOrFinish(context, ref, currentStep)
                    : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  currentStep == 2 ? l10n.saveChanges : l10n.next,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed(int step, MedicationFormData formData) => switch (step) {
    0 => formData.isStep1Valid,
    1 => formData.isStep2Valid,
    2 => formData.isStep3Valid,
    _ => false,
  };

  void _onNextOrFinish(BuildContext context, WidgetRef ref, int currentStep) {
    if (currentStep < 2) {
      ref.read(currentStepProvider.notifier).nextStep();
    } else {
      MedicationEditActions.save(
        context: context,
        ref: ref,
        medicationId: medicationId,
      );
    }
  }
}
