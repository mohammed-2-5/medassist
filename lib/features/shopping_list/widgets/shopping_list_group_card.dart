import 'package:flutter/material.dart';
import 'package:med_assist/features/shopping_list/models/shopping_list_item.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class ShoppingListGroupCard extends StatelessWidget {
  const ShoppingListGroupCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    super.key,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<ShoppingListItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Text(
                    '${items.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final item in items)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.medication.medicineName),
                subtitle: Text(_subtitleForItem(item, l10n)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item.suggestedQuantity}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _subtitleForItem(ShoppingListItem item, AppLocalizations l10n) {
    if (item.isExpired) {
      return l10n.expired;
    }

    if (item.isExpiringSoon && item.daysUntilExpiry != null) {
      return l10n.expiresInDays(item.daysUntilExpiry!);
    }

    final stockDays = item.daysRemaining.ceil();
    return l10n.daysOfStockLeft(stockDays);
  }
}
