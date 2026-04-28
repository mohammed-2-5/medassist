import 'package:flutter/material.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';
import 'package:med_assist/features/stock/utils/stock_card_utils.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Expiry date row shown inside StockCard when a medication has an expiry date.
class StockExpiryInfo extends StatelessWidget {
  const StockExpiryInfo({
    required this.stock,
    super.key,
  });

  final MedicationStock stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final expiryColor = stock.isExpired
        ? Colors.red
        : stock.isExpiringSoon
        ? Colors.orange
        : Colors.green;

    final expiryIcon = stock.isExpired
        ? Icons.error
        : stock.isExpiringSoon
        ? Icons.warning_amber
        : Icons.check_circle;

    final statusText = getExpiryStatusText(
      stock.isExpired,
      stock.daysUntilExpiry,
      context,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: expiryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: expiryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(expiryIcon, color: expiryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.expiryDateLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatExpiryDate(stock.expiryDate!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: expiryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
