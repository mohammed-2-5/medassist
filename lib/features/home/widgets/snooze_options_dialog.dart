import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Dialog to let user choose snooze duration
class SnoozeOptionsDialog extends StatelessWidget {
  const SnoozeOptionsDialog({
    required this.medicationName,
    super.key,
  });
  final String medicationName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.snooze, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.snoozeReminder,
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  medicationName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.howLongSnooze,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _SnoozeOption(
              icon: Icons.timer,
              label: l10n.fiveMinutes,
              minutes: 5,
              onTap: () => Navigator.of(context).pop(5),
            ),
            const SizedBox(height: 8),
            _SnoozeOption(
              icon: Icons.timer,
              label: l10n.tenMinutes,
              minutes: 10,
              onTap: () => Navigator.of(context).pop(10),
            ),
            const SizedBox(height: 8),
            _SnoozeOption(
              icon: Icons.timer,
              label: l10n.fifteenMinutes,
              minutes: 15,
              onTap: () => Navigator.of(context).pop(15),
            ),
            const SizedBox(height: 8),
            _SnoozeOption(
              icon: Icons.timer_outlined,
              label: l10n.thirtyMinutes,
              minutes: 30,
              onTap: () => Navigator.of(context).pop(30),
            ),
            const SizedBox(height: 8),
            _SnoozeOption(
              icon: Icons.timer_outlined,
              label: l10n.oneHour,
              minutes: 60,
              onTap: () => Navigator.of(context).pop(60),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

class _SnoozeOption extends StatelessWidget {
  const _SnoozeOption({
    required this.icon,
    required this.label,
    required this.minutes,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final int minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
