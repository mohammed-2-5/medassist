import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/stock_utils.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MedicationDetailStockCard extends StatelessWidget {
  const MedicationDetailStockCard({required this.medication, super.key});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final days = StockUtils.daysRemaining(medication);
    final daysRemaining = days < 0 ? 0 : days;
    final stockPercentage =
        (medication.stockQuantity > 0 && medication.durationDays > 0)
            ? (daysRemaining / medication.durationDays).clamp(0.0, 1.0)
            : 0.0;
    final stockColor = daysRemaining > 7
        ? Colors.green
        : daysRemaining > 3
            ? Colors.orange
            : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: stockColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stockColor.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, size: 20, color: stockColor),
              const SizedBox(width: 8),
              Text(
                l10n.stockStatus,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${medication.stockQuantity} ${medication.doseUnit}s',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stockColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.available,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$daysRemaining days',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stockColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.remaining,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stockPercentage,
              minHeight: 12,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(stockColor),
            ),
          ),
          if (daysRemaining <= 3) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.lowStockAlert,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
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
    );
  }
}
