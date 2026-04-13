import 'package:flutter/material.dart';
import 'package:med_assist/features/medications/widgets/interaction_warning_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';

/// Dialog shown when drug interactions are found during medication add flow.
/// Returns true if user wants to proceed anyway, false/null to cancel.
class InteractionCheckDialog extends StatelessWidget {
  const InteractionCheckDialog({
    required this.warnings,
    super.key,
  });

  final List<InteractionWarning> warnings;

  static Future<bool> show(
    BuildContext context,
    List<InteractionWarning> warnings,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InteractionCheckDialog(warnings: warnings),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 40),
      title: Text(l10n.interactionWarningTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.interactionWarningMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: warnings.length,
                itemBuilder: (context, index) => InteractionWarningCard(
                  warning: warnings[index],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
          ),
          child: Text(l10n.addAnyway),
        ),
      ],
    );
  }
}
