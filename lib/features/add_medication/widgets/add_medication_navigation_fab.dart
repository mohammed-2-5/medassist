import 'package:flutter/material.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Back/Next/Finish navigation buttons for the add medication wizard.
class AddMedicationNavigationFab extends StatelessWidget {
  const AddMedicationNavigationFab({
    required this.currentStep,
    required this.formData,
    required this.onBack,
    required this.onNext,
    this.isSaving = false,
    super.key,
  });

  final int currentStep;
  final MedicationFormData formData;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool isSaving;

  bool get _canProceed {
    switch (currentStep) {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final enabled = _canProceed && !isSaving;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (currentStep > 0)
            FloatingActionButton(
              onPressed: isSaving ? null : onBack,
              heroTag: 'back',
              child: const Icon(Icons.arrow_back),
            ),
          const Spacer(),
          FloatingActionButton.extended(
            onPressed: enabled ? onNext : null,
            heroTag: 'next',
            backgroundColor: enabled
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            label: Text(
              currentStep < 2 ? l10n.next : l10n.finish,
              style: TextStyle(
                color: enabled
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: isSaving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : Icon(
                    currentStep < 2 ? Icons.arrow_forward : Icons.check,
                    color: enabled
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
          ),
        ],
      ),
    );
  }
}
