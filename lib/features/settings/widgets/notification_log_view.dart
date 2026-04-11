import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class NotificationLogView extends StatelessWidget {
  const NotificationLogView({
    required this.l10n,
    required this.pending,
    super.key,
  });

  final AppLocalizations l10n;
  final List<Map<String, dynamic>> pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.pendingNotifications} (${pending.length})',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              Text(
                l10n.noRemindersSet,
                style: const TextStyle(color: Colors.grey),
              )
            else
              ...pending.map((item) => _NotificationLogItem(item: item)),
          ],
        ),
      ),
    );
  }
}

class _NotificationLogItem extends StatelessWidget {
  const _NotificationLogItem({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${item['id'] ?? 'N/A'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (item['title'] as String?) ?? 'No title',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              (item['body'] as String?) ?? 'No body',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
