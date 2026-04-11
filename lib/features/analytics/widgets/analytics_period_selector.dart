import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Horizontal segmented-button row for selecting the analytics time period.
///
/// Periods: 0 = Today, 1 = Week, 2 = Month, 3 = Year, 4 = Custom.
class AnalyticsPeriodSelector extends StatelessWidget {
  const AnalyticsPeriodSelector({
    required this.selectedPeriod,
    required this.onSelectionChanged,
    super.key,
  });

  final int selectedPeriod;
  final ValueChanged<int> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final horizontalPadding = isCompact ? 12.0 : 20.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text(l10n.today),
                    icon: const Icon(Icons.today),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text(l10n.week),
                    icon: const Icon(Icons.view_week),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text(l10n.month),
                    icon: const Icon(Icons.calendar_month),
                  ),
                  ButtonSegment(
                    value: 3,
                    label: Text(l10n.year),
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
                selected: {selectedPeriod},
                onSelectionChanged: (Set<int> newSelection) =>
                    onSelectionChanged(newSelection.first),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return colorScheme.onPrimaryContainer;
                    }
                    return colorScheme.surfaceContainerHighest;
                  }),
                  foregroundColor:
                      WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return colorScheme.onSurfaceVariant;
                  }),
                  iconColor:
                      WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return colorScheme.primary;
                  }),
                  side: WidgetStateProperty.resolveWith<BorderSide>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return BorderSide(
                          color: colorScheme.primary, width: 2);
                    }
                    return BorderSide(color: colorScheme.outlineVariant);
                  }),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
