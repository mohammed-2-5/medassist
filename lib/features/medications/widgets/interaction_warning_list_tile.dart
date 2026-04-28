import 'package:flutter/material.dart';
import 'package:med_assist/features/medications/widgets/interaction_severity_style.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';

/// Compact tile for displaying an interaction warning in a list.
class InteractionWarningListTile extends StatelessWidget {
  const InteractionWarningListTile({
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

    return ListTile(
      leading: Icon(
        InteractionSeverityStyle.icon(warning.severity),
        color: severityColor,
      ),
      title: Text(
        '${warning.medication1} + ${warning.medication2}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        warning.descriptionFor(lang),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: severityColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          DrugInteractionService.severityLabel(
            warning.severity,
            l10n,
          ).toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
