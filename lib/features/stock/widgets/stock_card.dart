import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';
import 'package:med_assist/features/stock/widgets/stock_adjustment_dialog.dart';

/// Card displaying medication stock information
class StockCard extends ConsumerWidget {

  const StockCard({
    required this.medicationStock,
    required this.onStockAdjusted,
    super.key,
  });
  final MedicationStock medicationStock;
  final VoidCallback onStockAdjusted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final medication = medicationStock.medication;
    final stockColor = _getStockColor(medicationStock.stockLevel);

    return Card(
      child: InkWell(
        onTap: () => _showStockAdjustmentDialog(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with medication name and stock level indicator
              Row(
                children: [
                  // Stock level indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: stockColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Medication info
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

                  // Stock level badge
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
                      _getStockLevelText(medicationStock.stockLevel),
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
                    child: _buildInfoColumn(
                      context,
                      'Current Stock',
                      '${medicationStock.currentStock} ${medication.doseUnit}',
                      Icons.inventory_2,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      context,
                      'Days Remaining',
                      medicationStock.daysRemaining >= 999
                          ? '∞'
                          : '${medicationStock.daysRemaining.toStringAsFixed(1)} days',
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),

              // Expiry information
              if (medicationStock.expiryDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildExpiryInfo(context, theme, colorScheme),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _getProgressValue(medicationStock.daysRemaining),
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                ),
              ),

              const SizedBox(height: 12),

              // Warning messages
              if (medicationStock.stockLevel == StockLevel.critical ||
                  medicationStock.stockLevel == StockLevel.low) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: stockColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: stockColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getWarningMessage(medicationStock.stockLevel),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: stockColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Expiry warning
              if (medicationStock.isExpired || medicationStock.isExpiringSoon) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: medicationStock.isExpired
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        medicationStock.isExpired ? Icons.error : Icons.warning_amber,
                        color: medicationStock.isExpired ? Colors.red : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          medicationStock.isExpired
                              ? 'This medication has expired! Do not use.'
                              : 'This medication is expiring soon (${medicationStock.daysUntilExpiry} days).',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: medicationStock.isExpired ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Adjust stock button
              Center(
                child: TextButton.icon(
                  onPressed: () => _showStockAdjustmentDialog(context, ref),
                  icon: const Icon(Icons.edit),
                  label: const Text('Adjust Stock'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStockColor(StockLevel level) {
    switch (level) {
      case StockLevel.critical:
        return Colors.red;
      case StockLevel.low:
        return Colors.orange;
      case StockLevel.medium:
        return Colors.yellow.shade700;
      case StockLevel.good:
        return Colors.green;
    }
  }

  String _getStockLevelText(StockLevel level) {
    switch (level) {
      case StockLevel.critical:
        return 'CRITICAL';
      case StockLevel.low:
        return 'LOW';
      case StockLevel.medium:
        return 'MEDIUM';
      case StockLevel.good:
        return 'GOOD';
    }
  }

  String _getWarningMessage(StockLevel level) {
    switch (level) {
      case StockLevel.critical:
        return 'Critical stock level! Refill immediately.';
      case StockLevel.low:
        return 'Low stock level. Consider refilling soon.';
      default:
        return '';
    }
  }

  double _getProgressValue(double daysRemaining) {
    if (daysRemaining >= 14) return 1;
    return (daysRemaining / 14).clamp(0.0, 1.0);
  }

  void _showStockAdjustmentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => StockAdjustmentDialog(
        medication: medicationStock.medication,
        currentStock: medicationStock.currentStock,
        onAdjusted: onStockAdjusted,
      ),
    );
  }

  Widget _buildExpiryInfo(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final expiryColor = medicationStock.isExpired
        ? Colors.red
        : medicationStock.isExpiringSoon
            ? Colors.orange
            : Colors.green;

    final expiryIcon = medicationStock.isExpired
        ? Icons.error
        : medicationStock.isExpiringSoon
            ? Icons.warning_amber
            : Icons.check_circle;

    String expiryText;
    if (medicationStock.isExpired) {
      expiryText = 'Expired';
    } else if (medicationStock.daysUntilExpiry != null) {
      final days = medicationStock.daysUntilExpiry!;
      expiryText = days == 0
          ? 'Expires today'
          : days == 1
              ? 'Expires tomorrow'
              : 'Expires in $days days';
    } else {
      expiryText = 'Good';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: expiryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: expiryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            expiryIcon,
            color: expiryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expiry Date',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(medicationStock.expiryDate!),
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
              expiryText,
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
