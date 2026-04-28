import 'package:flutter/material.dart';
import 'package:med_assist/features/medications/models/display_drug_info.dart';
import 'package:med_assist/features/medications/widgets/drug_info_sub_widgets.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Full drug info content card rendered when data is available.
class DrugInfoContentCard extends StatelessWidget {
  const DrugInfoContentCard({
    required this.info,
    this.onRefresh,
    super.key,
  });

  final DisplayDrugInfo info;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
          // Title row with AI badge
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.drugInformation,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onRefresh != null)
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  tooltip: l10n.drugInfoRefresh,
                  onPressed: onRefresh,
                  visualDensity: VisualDensity.compact,
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

          if (info.howToTake != null || info.bestTimeOfDay != null) ...[
            const SizedBox(height: 12),
            DrugInfoHighlightedSection(
              icon: Icons.schedule,
              title: l10n.howToTake,
              color: colorScheme.primary,
              children: [
                if (info.howToTake != null)
                  DrugInfoLabeledValue(
                    label: l10n.howToTake,
                    value: info.howToTake!,
                  ),
                if (info.bestTimeOfDay != null)
                  DrugInfoLabeledValue(
                    label: l10n.bestTimeOfDay,
                    value: info.bestTimeOfDay!,
                  ),
              ],
            ),
          ],

          if (info.hasBasics) ...[
            const SizedBox(height: 12),
            if (info.genericName != null)
              DrugInfoBasicRow(
                label: l10n.genericName,
                value: info.genericName!,
              ),
            if (info.activeIngredients != null)
              DrugInfoBasicRow(
                label: l10n.activeIngredients,
                value: info.activeIngredients!,
              ),
            if (info.drugCategory != null)
              DrugInfoBasicRow(
                label: l10n.drugCategory,
                value: info.drugCategory!,
              ),
            if (info.purpose != null)
              DrugInfoBasicRow(label: l10n.purpose, value: info.purpose!),
            if (info.route != null)
              DrugInfoBasicRow(label: l10n.drugRoute, value: info.route!),
            if (info.otcOrPrescription != null)
              DrugInfoBasicRow(
                label: l10n.otcOrPrescription,
                value: info.otcOrPrescription!,
              ),
          ],

          if (info.sideEffects != null) ...[
            const SizedBox(height: 8),
            DrugInfoHighlightedSection(
              icon: Icons.warning_amber_rounded,
              title: l10n.sideEffects,
              color: Colors.orange.shade700,
              children: [
                Text(info.sideEffects!, style: theme.textTheme.bodySmall),
              ],
            ),
          ],

          if (info.hasWatchOut) ...[
            const SizedBox(height: 8),
            DrugInfoHighlightedSection(
              icon: Icons.shield_outlined,
              title: l10n.watchOut,
              color: colorScheme.error,
              children: [
                if (info.warnings != null)
                  DrugInfoLabeledValue(
                    label: l10n.drugWarnings,
                    value: info.warnings!,
                  ),
                if (info.hasDrowsinessWarning)
                  DrugInfoLabeledValue(
                    label: l10n.drowsinessWarning,
                    value: info.drowsinessMessage(l10n),
                  ),
                if (info.foodsToAvoid != null)
                  DrugInfoLabeledValue(
                    label: l10n.foodsToAvoid,
                    value: info.foodsToAvoid!,
                  ),
                if (info.alcoholWarning != null)
                  DrugInfoLabeledValue(
                    label: l10n.alcoholWarning,
                    value: info.alcoholWarning!,
                  ),
                if (info.contraindications != null)
                  DrugInfoLabeledValue(
                    label: l10n.contraindications,
                    value: info.contraindications!,
                  ),
              ],
            ),
          ],

          if (info.requiresMonitoring != null) ...[
            const SizedBox(height: 8),
            DrugInfoHighlightedSection(
              icon: Icons.monitor_heart_outlined,
              title: l10n.requiresMonitoring,
              color: colorScheme.tertiary,
              children: [
                Text(
                  info.requiresMonitoring!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],

          if (info.missedDoseAdvice != null ||
              info.storageInstructions != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (info.missedDoseAdvice != null)
                  Expanded(
                    child: DrugInfoMiniTile(
                      icon: Icons.alarm,
                      title: l10n.missedDoseAdvice,
                      value: info.missedDoseAdvice!,
                    ),
                  ),
                if (info.missedDoseAdvice != null &&
                    info.storageInstructions != null)
                  const SizedBox(width: 8),
                if (info.storageInstructions != null)
                  Expanded(
                    child: DrugInfoMiniTile(
                      icon: Icons.inventory_2_outlined,
                      title: l10n.storageInstructions,
                      value: info.storageInstructions!,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
