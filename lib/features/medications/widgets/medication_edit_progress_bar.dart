import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Step progress bar shown at the top of the medication edit/add wizard.
class MedicationEditProgressBar extends StatelessWidget {
  const MedicationEditProgressBar({required this.currentStep, super.key});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _StepIndicator(step: 0, currentStep: currentStep, label: l10n.type),
          _StepConnector(isCompleted: currentStep >= 1),
          _StepIndicator(step: 1, currentStep: currentStep, label: l10n.schedule),
          _StepConnector(isCompleted: currentStep >= 2),
          _StepIndicator(step: 2, currentStep: currentStep, label: l10n.stock),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.step,
    required this.currentStep,
    required this.label,
  });

  final int step;
  final int currentStep;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = step == currentStep;
    final isCompleted = step < currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, size: 20, color: colorScheme.onPrimary)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isCompleted
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
