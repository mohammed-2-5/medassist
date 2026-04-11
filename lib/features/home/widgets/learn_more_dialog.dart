import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Dialog explaining the key features of the app.
class LearnMoreDialog extends StatelessWidget {
  const LearnMoreDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.howMedAssistWorks),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LearnMoreItem(
            icon: Icons.alarm,
            title: l10n.smartReminders,
            description: l10n.smartRemindersDescription,
          ),
          const SizedBox(height: 16),
          _LearnMoreItem(
            icon: Icons.cloud_off,
            title: l10n.privateData,
            description: l10n.privateDataDescription,
          ),
          const SizedBox(height: 16),
          _LearnMoreItem(
            icon: Icons.schedule,
            title: l10n.flexibleSnoozing,
            description: l10n.flexibleSnoozingDescription,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.gotIt),
        ),
      ],
    );
  }
}

/// A single item in the "Learn More" dialog, with an icon, title, and description.
class _LearnMoreItem extends StatelessWidget {

  const _LearnMoreItem({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
