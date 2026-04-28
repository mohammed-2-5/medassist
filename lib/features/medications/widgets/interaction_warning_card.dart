import 'package:flutter/material.dart';
import 'package:med_assist/features/medications/widgets/interaction_drug_pill.dart';
import 'package:med_assist/features/medications/widgets/interaction_severity_style.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';

/// Card displaying a single drug interaction warning.
/// Shows where the conflict is, what can happen and what to do.
class InteractionWarningCard extends StatelessWidget {
  const InteractionWarningCard({
    required this.warning,
    this.onTap,
    super.key,
  });

  final InteractionWarning warning;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final severityColor = InteractionSeverityStyle.color(
      warning.severity,
      colorScheme,
    );
    final containerBg = InteractionSeverityStyle.containerColor(
      warning.severity,
      colorScheme,
    );
    final isSameDrug = warning.medication1 == warning.medication2;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: severityColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: severityColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Severity chip
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          InteractionSeverityStyle.icon(warning.severity),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DrugInteractionService.severityLabel(
                            warning.severity,
                            l10n,
                          ).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DrugInteractionService.severityDescription(
                        warning.severity,
                        l10n,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Drug conflict row
              if (!isSameDrug) ...[
                Text(
                  l10n.conflictBetween,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: InteractionDrugPill(
                        name: warning.medication1,
                        color: severityColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.compare_arrows_rounded,
                        color: severityColor,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: InteractionDrugPill(
                        name: warning.medication2,
                        color: severityColor,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                InteractionDrugPill(
                  name: warning.medication1,
                  color: severityColor,
                ),
              ],

              const SizedBox(height: 12),

              _InfoBlock(
                icon: Icons.help_outline_rounded,
                label: l10n.whatHappens,
                text: warning.descriptionFor(lang),
                color: severityColor,
                bg: containerBg,
              ),
              const SizedBox(height: 8),
              _InfoBlock(
                icon: Icons.lightbulb_outline_rounded,
                label: l10n.whatToDo,
                text: warning.recommendationFor(lang),
                color: colorScheme.primary,
                bg: colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),

              // Evidence
              if (warning.evidence != null && warning.evidence!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        warning.evidence!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.label,
    required this.text,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String label;
  final String text;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
