import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';
import 'package:med_assist/features/stock/utils/stock_card_utils.dart';
import 'package:med_assist/features/stock/widgets/stock_adjustment_dialog.dart';
import 'package:med_assist/features/stock/widgets/stock_expiry_info.dart';
import 'package:med_assist/features/stock/widgets/stock_info_column.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Card displaying medication stock information
class StockCard extends ConsumerWidget {
  const StockCard({
    required this.medicationStock, required this.onStockAdjusted, super.key,
  });

  final MedicationStock medicationStock;
  final VoidCallback onStockAdjusted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final medication = medicationStock.medication;
    final stockColor = getStockLevelColor(medicationStock.stockLevel);

    return Card(
      child: InkWell(
        onTap: () => _showAdjustDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: stockColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.medicineName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          medication.medicineType,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getStockLevelLabel(medicationStock.stockLevel, context),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: stockColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stock details
              Row(
                children: [
                  Expanded(
                    child: StockInfoColumn(
                      label: l10n.currentStockLabel,
                      value: '${medicationStock.currentStock} ${medication.doseUnit}',
                      icon: Icons.inventory_2,
                    ),
                  ),
                  Expanded(
                    child: StockInfoColumn(
                      label: l10n.daysRemainingLabel,
                      value: medicationStock.daysRemaining >= 999
                          ? '∞'
                          : '${medicationStock.daysRemaining.toStringAsFixed(1)} days',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ],
              ),

              // Expiry info
              if (medicationStock.expiryDate != null) ...[
                const SizedBox(height: 12),
                StockExpiryInfo(stock: medicationStock),
              ],

              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: getStockProgressValue(medicationStock.daysRemaining),
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                ),
              ),

              // Stock warning
              if (medicationStock.stockLevel == StockLevel.critical ||
                  medicationStock.stockLevel == StockLevel.low) ...[
                const SizedBox(height: 12),
                _StockWarningBanner(
                  message: getStockWarningMessage(medicationStock.stockLevel, context),
                  color: stockColor,
                ),
              ],

              // Expired/expiring warning
              if (medicationStock.isExpired || medicationStock.isExpiringSoon) ...[
                const SizedBox(height: 8),
                _ExpiryWarningBanner(stock: medicationStock),
              ],

              const SizedBox(height: 8),

              Center(
                child: TextButton.icon(
                  onPressed: () => _showAdjustDialog(context),
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.adjustStock),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdjustDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => StockAdjustmentDialog(
        medication: medicationStock.medication,
        currentStock: medicationStock.currentStock,
        onAdjusted: onStockAdjusted,
      ),
    );
  }
}

class _StockWarningBanner extends StatelessWidget {
  const _StockWarningBanner({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryWarningBanner extends StatelessWidget {
  const _ExpiryWarningBanner({required this.stock});

  final MedicationStock stock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = stock.isExpired ? Colors.red : Colors.orange;
    final icon = stock.isExpired ? Icons.error : Icons.warning_amber;
    final message = stock.isExpired
        ? l10n.medicationExpiredWarning
        : l10n.medicationExpiringSoonWarning(stock.daysUntilExpiry ?? 0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
