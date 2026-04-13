import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MedicationDetailDrugInfoCard extends StatelessWidget {
  const MedicationDetailDrugInfoCard({
    required this.medication,
    super.key,
  });

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.drugInformation,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AI',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (medication.genericName != null)
            _DrugInfoRow(
              icon: Icons.label_outline,
              label: l10n.genericName,
              value: medication.genericName!,
            ),
          if (medication.activeIngredients != null)
            _DrugInfoRow(
              icon: Icons.science_outlined,
              label: l10n.activeIngredients,
              value: medication.activeIngredients!,
            ),
          if (medication.drugCategory != null)
            _DrugInfoRow(
              icon: Icons.category_outlined,
              label: l10n.drugCategory,
              value: medication.drugCategory!,
            ),
          if (medication.purpose != null)
            _DrugInfoRow(
              icon: Icons.healing_outlined,
              label: l10n.purpose,
              value: medication.purpose!,
            ),
          if (medication.route != null)
            _DrugInfoRow(
              icon: Icons.route_outlined,
              label: l10n.drugRoute,
              value: medication.route!,
            ),
          if (medication.sideEffects != null) ...[
            const Divider(height: 20),
            _DrugInfoSection(
              icon: Icons.warning_amber_rounded,
              label: l10n.sideEffects,
              value: medication.sideEffects!,
              color: Colors.orange,
            ),
          ],
          if (medication.warnings != null) ...[
            const SizedBox(height: 8),
            _DrugInfoSection(
              icon: Icons.shield_outlined,
              label: l10n.drugWarnings,
              value: medication.warnings!,
              color: colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }
}

class _DrugInfoRow extends StatelessWidget {
  const _DrugInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrugInfoSection extends StatelessWidget {
  const _DrugInfoSection({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
