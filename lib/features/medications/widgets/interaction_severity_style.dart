import 'package:flutter/material.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';

/// Shared severity colours, container colours and icons for interaction UI.
class InteractionSeverityStyle {
  const InteractionSeverityStyle._();

  static Color color(
    InteractionSeverity severity,
    ColorScheme colorScheme,
  ) {
    switch (severity) {
      case InteractionSeverity.minor:
        return Colors.green.shade600;
      case InteractionSeverity.moderate:
        return Colors.orange.shade700;
      case InteractionSeverity.major:
        return Colors.deepOrange.shade700;
      case InteractionSeverity.severe:
        return colorScheme.error;
    }
  }

  static Color containerColor(
    InteractionSeverity severity,
    ColorScheme colorScheme,
  ) {
    switch (severity) {
      case InteractionSeverity.minor:
        return Colors.green.shade50;
      case InteractionSeverity.moderate:
        return Colors.orange.shade50;
      case InteractionSeverity.major:
        return Colors.deepOrange.shade50;
      case InteractionSeverity.severe:
        return colorScheme.errorContainer.withValues(alpha: 0.4);
    }
  }

  static IconData icon(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.minor:
        return Icons.info_outline;
      case InteractionSeverity.moderate:
        return Icons.warning_amber_rounded;
      case InteractionSeverity.major:
        return Icons.error_outline;
      case InteractionSeverity.severe:
        return Icons.dangerous_outlined;
    }
  }
}
