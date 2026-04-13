import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Progress indicator showing the 3-step wizard state.
class AddMedicationProgressIndicator extends StatelessWidget {
  const AddMedicationProgressIndicator({
    required this.currentStep,
    super.key,
  });

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          _buildStepCircle(0, l10n.type, colorScheme, theme),
          _buildConnector(currentStep >= 1, colorScheme),
          _buildStepCircle(1, l10n.schedule, colorScheme, theme),
          _buildConnector(currentStep >= 2, colorScheme),
          _buildStepCircle(2, l10n.stock, colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildStepCircle(
    int step,
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
}
