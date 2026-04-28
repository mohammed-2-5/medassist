import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/dose_unit_localizer.dart';
import 'package:med_assist/features/medications/widgets/medication_card_stock_indicator.dart';
import 'package:med_assist/l10n/app_localizations.dart';

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
        _buildDosageInfo(context),
        const SizedBox(height: 12),
        _buildScheduleSummary(context),
        const SizedBox(height: 12),
        MedicationCardStockIndicator(
          medication: medication,
          theme: theme,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildDosageInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amount = medication.dosePerTime;
    final unit = localizeDoseUnit(l10n, medication.doseUnit);
    final amountStr = amount == amount.toInt()
        ? amount.toInt().toString()
        : amount.toString();

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.medication, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$amountStr $unit',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.schedule, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.xTimesPerDay(medication.timesPerDay),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  ? l10n.treatmentDaysRemaining(daysRemaining)
                  : l10n.treatmentCompleted,
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
