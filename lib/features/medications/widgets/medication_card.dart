import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';

/// Beautiful medication card with modern medical design
class MedicationCard extends StatelessWidget {

  const MedicationCard({
    required this.medication,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    super.key,
  });
  final Medication medication;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key('med_${medication.id}'),
      background: _buildSwipeBackground(colorScheme, true),
      secondaryBackground: _buildSwipeBackground(colorScheme, false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDelete();
          return false; // Don't dismiss, let the dialog handle it
        } else {
          onEdit();
          return false;
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: medication.isActive
              ? BorderSide.none
              : BorderSide(
                  color: colorScheme.outline.withOpacity(0.5),
                  width: 2,
                ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: medication.isActive
                  ? null
                  : LinearGradient(
                      colors: [
                        colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        colorScheme.surface,
                      ],
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Medicine icon/emoji
                    _buildMedicineIcon(colorScheme),
                    const SizedBox(width: 12),

                    // Name and type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.medicineName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: medication.isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildTypeBadge(theme, colorScheme),
                        ],
                      ),
                    ),

                    // Status chip
                    _buildStatusChip(theme, colorScheme),
                  ],
                ),

                const SizedBox(height: 16),

                // Dosage info
                _buildDosageInfo(theme, colorScheme),

                const SizedBox(height: 12),

                // Schedule summary
                _buildScheduleSummary(theme, colorScheme),

                const SizedBox(height: 12),

                // Stock indicator
                _buildStockIndicator(theme, colorScheme),

                const SizedBox(height: 12),

                // Action buttons
                _buildActionButtons(theme, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(ColorScheme colorScheme, bool isEdit) {
    return Container(
      alignment: isEdit ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isEdit ? colorScheme.primary : colorScheme.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isEdit ? Icons.edit : Icons.delete,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildMedicineIcon(ColorScheme colorScheme) {
    final medicineType = MedicineType.values.firstWhere(
      (type) => type.name == medication.medicineType,
      orElse: () => MedicineType.pill,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: medication.isActive
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        medicineType.label.split(' ')[0], // Get emoji
        style: const TextStyle(fontSize: 28),
      ),
    );
  }

  Widget _buildTypeBadge(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getMedicineTypeLabel(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getMedicineTypeLabel() {
    final medicineType = MedicineType.values.firstWhere(
      (type) => type.name == medication.medicineType,
      orElse: () => MedicineType.pill,
    );
    return medicineType.label.substring(2); // Remove emoji
  }

  Widget _buildStatusChip(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: medication.isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: medication.isActive ? Colors.green : Colors.orange,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: medication.isActive ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            medication.isActive ? 'Active' : 'Paused',
            style: theme.textTheme.labelSmall?.copyWith(
              color: medication.isActive ? Colors.green.shade700 : Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosageInfo(ThemeData theme, ColorScheme colorScheme) {
    final amount = medication.dosePerTime;
    final unit = medication.doseUnit;
    final amountStr = amount == amount.toInt()
        ? amount.toInt().toString()
        : amount.toString();

    return Row(
      children: [
        Icon(
          Icons.medication,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '$amountStr $unit',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.schedule,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '${medication.timesPerDay}x per day',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSummary(ThemeData theme, ColorScheme colorScheme) {
    final daysRemaining = medication.startDate
        .add(Duration(days: medication.durationDays))
        .difference(DateTime.now())
        .inDays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              daysRemaining > 0
                  ? 'Treatment: $daysRemaining day${daysRemaining != 1 ? 's' : ''} remaining'
                  : 'Treatment completed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockIndicator(ThemeData theme, ColorScheme colorScheme) {
    final dailyUsage = medication.dosePerTime * medication.timesPerDay;
    final daysRemaining = medication.stockQuantity > 0
        ? (medication.stockQuantity / dailyUsage).floor()
        : 0;

    final stockPercentage = medication.stockQuantity > 0
        ? (daysRemaining / medication.durationDays).clamp(0.0, 1.0)
        : 0.0;

    final stockColor = daysRemaining > 7
        ? Colors.green
        : daysRemaining > 3
            ? Colors.orange
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  size: 16,
                  color: stockColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock: ${medication.stockQuantity} ${medication.doseUnit}${medication.stockQuantity != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '$daysRemaining day${daysRemaining != 1 ? 's' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: stockColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: stockPercentage,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(stockColor),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onToggleActive,
            icon: Icon(
              medication.isActive ? Icons.pause : Icons.play_arrow,
              size: 16,
            ),
            label: Text(medication.isActive ? 'Pause' : 'Resume'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
