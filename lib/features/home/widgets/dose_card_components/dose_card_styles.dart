import 'package:flutter/material.dart';
import 'package:med_assist/features/home/models/dose_event.dart';

/// Helper class for dose card styling based on status
class DoseCardStyles {
  DoseCardStyles(this.colorScheme, this.status);
  final ColorScheme colorScheme;
  final DoseStatus status;

  Color get cardColor {
    switch (status) {
      case DoseStatus.pending:
        return colorScheme.surface;
      case DoseStatus.taken:
        return colorScheme.secondaryContainer.withOpacity(0.3);
      case DoseStatus.missed:
        return colorScheme.errorContainer.withOpacity(0.3);
      case DoseStatus.skipped:
        return colorScheme.surfaceContainerHighest.withOpacity(0.5);
      case DoseStatus.snoozed:
        return colorScheme.tertiaryContainer.withOpacity(0.3);
    }
  }

  Color get borderColor {
    switch (status) {
      case DoseStatus.pending:
        return colorScheme.outlineVariant;
      case DoseStatus.taken:
        return colorScheme.secondary.withOpacity(0.3);
      case DoseStatus.missed:
        return colorScheme.error.withOpacity(0.3);
      case DoseStatus.skipped:
        return colorScheme.outlineVariant;
      case DoseStatus.snoozed:
        return colorScheme.tertiary.withOpacity(0.3);
    }
  }

  Color get iconBackgroundColor {
    switch (status) {
      case DoseStatus.pending:
        return colorScheme.primaryContainer;
      case DoseStatus.taken:
        return colorScheme.secondaryContainer;
      case DoseStatus.missed:
        return colorScheme.errorContainer;
      case DoseStatus.skipped:
        return colorScheme.surfaceContainerHighest;
      case DoseStatus.snoozed:
        return colorScheme.tertiaryContainer;
    }
  }

  Color get iconColor {
    switch (status) {
      case DoseStatus.pending:
        return colorScheme.primary;
      case DoseStatus.taken:
        return colorScheme.secondary;
      case DoseStatus.missed:
        return colorScheme.error;
      case DoseStatus.skipped:
        return colorScheme.onSurfaceVariant;
      case DoseStatus.snoozed:
        return colorScheme.tertiary;
    }
  }

  Color get timeBadgeColor {
    switch (status) {
      case DoseStatus.pending:
        return colorScheme.primaryContainer;
      case DoseStatus.taken:
        return colorScheme.secondaryContainer;
      case DoseStatus.missed:
        return colorScheme.errorContainer;
      case DoseStatus.skipped:
        return colorScheme.surfaceContainerHighest;
      case DoseStatus.snoozed:
        return colorScheme.tertiaryContainer;
    }
  }

  Color get timeBadgeTextColor {
    switch (status) {
      case DoseStatus.pending:
        return colorScheme.onPrimaryContainer;
      case DoseStatus.taken:
        return colorScheme.onSecondaryContainer;
      case DoseStatus.missed:
        return colorScheme.onErrorContainer;
      case DoseStatus.skipped:
        return colorScheme.onSurfaceVariant;
      case DoseStatus.snoozed:
        return colorScheme.onTertiaryContainer;
    }
  }

  Color get textColor => colorScheme.onSurface;

  bool get hasShadow => status == DoseStatus.pending;
}
