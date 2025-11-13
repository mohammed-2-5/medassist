import 'package:flutter/material.dart';

/// Dialog explaining the key features of the app.
class LearnMoreDialog extends StatelessWidget {
  const LearnMoreDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('How Med Assist Works'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LearnMoreItem(
            icon: Icons.alarm,
            title: 'Smart Reminders',
            description: 'Get timely alerts even when offline',
          ),
          SizedBox(height: 16),
          _LearnMoreItem(
            icon: Icons.cloud_off,
            title: '100% Private',
            description: 'All data stays on your device',
          ),
          SizedBox(height: 16),
          _LearnMoreItem(
            icon: Icons.schedule,
            title: 'Flexible Snoozing',
            description: "Snooze reminders when you're busy",
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
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
