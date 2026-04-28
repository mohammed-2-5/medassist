import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MedicationSavedDialog extends StatelessWidget {
  const MedicationSavedDialog({
    required this.hasDrugInfo,
    required this.hasInteractions,
    required this.interactionCount,
    super.key,
  });

  final bool hasDrugInfo;
  final bool hasInteractions;
  final int interactionCount;

  static Future<void> show(
    BuildContext context, {
    required bool hasDrugInfo,
    required bool hasInteractions,
    int interactionCount = 0,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MedicationSavedDialog(
        hasDrugInfo: hasDrugInfo,
        hasInteractions: hasInteractions,
        interactionCount: interactionCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: Icon(
        hasInteractions ? Icons.warning_amber_rounded : Icons.check_circle,
        color: hasInteractions ? Colors.orange : Colors.green,
        size: 56,
      ),
      title: Text(l10n.medicationSavedTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.medicationSavedMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (hasDrugInfo) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.drugInfoAddedHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasInteractions) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.interactionsFoundHint(interactionCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (hasInteractions)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.viewDetails),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(hasInteractions ? l10n.gotIt : l10n.done),
        ),
      ],
    );
  }
}
