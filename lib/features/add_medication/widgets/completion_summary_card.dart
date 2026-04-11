import 'package:flutter/material.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Summary card showing form completion status with step check items.
class CompletionSummaryCard extends StatelessWidget {
  const CompletionSummaryCard({required this.formData, super.key});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isComplete = formData.isComplete;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isComplete
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? colorScheme.secondary : colorScheme.outline,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.info,
            color: isComplete
                ? colorScheme.secondary
                : colorScheme.onSurfaceVariant,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            isComplete ? l10n.readyToSave : l10n.completeAllSteps,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isComplete
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isComplete ? l10n.medicineInfoComplete : l10n.fillRequiredFields,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isComplete
                  ? colorScheme.onSecondaryContainer.withOpacity(0.7)
                  : colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (isComplete) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _CheckItem(
                    label: l10n.medicineTypeAndDetails,
                    isValid: formData.isStep1Valid,
                  ),
                  const SizedBox(height: 8),
                  _CheckItem(
                    label: l10n.scheduleConfigured,
                    isValid: formData.isStep2Valid,
                  ),
                  const SizedBox(height: 8),
                  _CheckItem(
                    label: l10n.stockInformation,
                    isValid: formData.isStep3Valid,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.label, required this.isValid});

  final String label;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? Colors.green : colorScheme.onSurfaceVariant,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: isValid ? FontWeight.w600 : null,
            ),
          ),
        ),
      ],
    );
  }
}
