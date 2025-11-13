import 'package:flutter/material.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';

/// Card widget to display drug interaction warnings
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

    // Get severity-based colors
    final severityColor = _getSeverityColor(warning.severity, colorScheme);
    final backgroundColor = severityColor.withOpacity(0.1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with severity badge
              Row(
                children: [
                  // Warning icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getSeverityIcon(warning.severity),
                      color: severityColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Severity badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: severityColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            DrugInteractionService.getSeverityLabel(warning.severity)
                                .toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DrugInteractionService.getSeverityDescription(
                              warning.severity),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Medication pair
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        warning.medication1,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.close,
                      color: severityColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning.medication2,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                warning.description,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 12),

              // Recommendation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: severityColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: severityColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning.recommendation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(
    InteractionSeverity severity,
    ColorScheme colorScheme,
  ) {
    switch (severity) {
      case InteractionSeverity.minor:
        return Colors.green;
      case InteractionSeverity.moderate:
        return Colors.orange;
      case InteractionSeverity.major:
        return Colors.deepOrange;
      case InteractionSeverity.severe:
        return colorScheme.error;
    }
  }

  IconData _getSeverityIcon(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.minor:
        return Icons.info_outline;
      case InteractionSeverity.moderate:
        return Icons.warning_amber_rounded;
      case InteractionSeverity.major:
        return Icons.error_outline;
      case InteractionSeverity.severe:
        return Icons.dangerous;
    }
  }
}

/// Compact version for lists
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
    final severityColor = _getSeverityColor(warning.severity, colorScheme);

    return ListTile(
      leading: Icon(
        _getSeverityIcon(warning.severity),
        color: severityColor,
      ),
      title: Text(
        '${warning.medication1} + ${warning.medication2}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        warning.description,
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
          DrugInteractionService.getSeverityLabel(warning.severity).toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Color _getSeverityColor(
    InteractionSeverity severity,
    ColorScheme colorScheme,
  ) {
    switch (severity) {
      case InteractionSeverity.minor:
        return Colors.green;
      case InteractionSeverity.moderate:
        return Colors.orange;
      case InteractionSeverity.major:
        return Colors.deepOrange;
      case InteractionSeverity.severe:
        return colorScheme.error;
    }
  }

  IconData _getSeverityIcon(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.minor:
        return Icons.info_outline;
      case InteractionSeverity.moderate:
        return Icons.warning_amber_rounded;
      case InteractionSeverity.major:
        return Icons.error_outline;
      case InteractionSeverity.severe:
        return Icons.dangerous;
    }
  }
}
