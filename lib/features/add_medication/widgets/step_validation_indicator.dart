import 'package:flutter/material.dart';

/// Shows a valid/invalid indicator bar for a form step.
class StepValidationIndicator extends StatelessWidget {
  const StepValidationIndicator({
    required this.isValid,
    required this.validMessage,
    required this.invalidMessage,
    super.key,
  });

  final bool isValid;
  final String validMessage;
  final String invalidMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid
            ? colorScheme.secondaryContainer.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid ? colorScheme.secondary : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.info_outline,
            color: isValid
                ? colorScheme.secondary
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isValid ? validMessage : invalidMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isValid
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isValid ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
