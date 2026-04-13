import 'package:flutter/material.dart';
import 'package:med_assist/features/shopping_list/models/shopping_list_item.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class PharmacyChecklistCard extends StatelessWidget {
  const PharmacyChecklistCard({
    required this.items,
    required this.checkedMedicationIds,
    required this.onToggleMedication,
    super.key,
  });

  final List<ShoppingListItem> items;
  final Set<int> checkedMedicationIds;
  final ValueChanged<int> onToggleMedication;

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
            Text(
              l10n.shoppingListSubtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in items)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: checkedMedicationIds.contains(item.medication.id),
                onChanged: (_) => onToggleMedication(item.medication.id),
                title: Text(item.medication.medicineName),
                subtitle: Text('${l10n.total}: ${item.suggestedQuantity}'),
              ),
          ],
        ),
      ),
    );
  }
}
