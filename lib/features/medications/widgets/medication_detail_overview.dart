import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/dose_unit_localizer.dart';
import 'package:med_assist/features/medications/widgets/medication_detail_drug_info_card.dart';
import 'package:med_assist/features/medications/widgets/medication_detail_stock_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MedicationDetailOverview extends StatelessWidget {
  const MedicationDetailOverview({required this.medication, super.key});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).languageCode;
    final localizedDoseUnit = localizeDoseUnit(l10n, medication.doseUnit);
    final strengthValue = [medication.strength, medication.unit]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            icon: Icons.medication,
            title: l10n.dosage,
            children: [
              _InfoRow(
                label: l10n.strength,
                value: strengthValue,
              ),
              _InfoRow(
                label: l10n.perDose,
                value: '${medication.dosePerTime} $localizedDoseUnit',
              ),
              _InfoRow(
                label: l10n.frequency,
                value: l10n.xTimesPerDay(medication.timesPerDay),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.schedule,
            title: l10n.schedule,
            children: [
              _InfoRow(
                label: l10n.duration,
                value: l10n.daysCount(medication.durationDays),
              ),
              _InfoRow(
                label: l10n.started,
                value: DateFormat.yMMMd(
                  localeName,
                ).format(medication.startDate),
              ),
              _InfoRow(
                label: l10n.ends,
                value: DateFormat.yMMMd(localeName).format(
                  medication.startDate.add(
                    Duration(days: medication.durationDays),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MedicationDetailStockCard(medication: medication),
          const SizedBox(height: 12),
          MedicationDetailDrugInfoCard(medication: medication),
          if (medication.notes != null && medication.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.notes,
              title: l10n.notes,
              children: [
                Text(medication.notes!, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
