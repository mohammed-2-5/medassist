import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/medications/widgets/medication_card_stock_indicator.dart';

class MedicationCardInfo extends StatelessWidget {
  const MedicationCardInfo({
    required this.medication,
    required this.theme,
    required this.colorScheme,
    super.key,
  });

  final Medication medication;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDosageInfo(),
        const SizedBox(height: 12),
        _buildScheduleSummary(),
        const SizedBox(height: 12),
        MedicationCardStockIndicator(
          medication: medication,
          theme: theme,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildDosageInfo() {
    final amount = medication.dosePerTime;
    final unit = medication.doseUnit;
    final amountStr = amount == amount.toInt()
        ? amount.toInt().toString()
        : amount.toString();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medication, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '$amountStr $unit',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '${medication.timesPerDay}x per day',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleSummary() {
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
          Icon(Icons.calendar_today, size: 16, color: colorScheme.primary),
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

}
