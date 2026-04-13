import 'package:flutter/material.dart';
import 'package:med_assist/features/analytics/models/analytics_period_option.dart';
import 'package:med_assist/features/analytics/widgets/analytics_period_pill.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Modern animated pill selector for analytics time period.
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

    final options = <AnalyticsPeriodOption>[
      AnalyticsPeriodOption(
        value: 0,
        label: l10n.today,
        icon: Icons.wb_sunny_rounded,
      ),
      AnalyticsPeriodOption(
        value: 1,
        label: l10n.week,
        icon: Icons.view_week_rounded,
      ),
      AnalyticsPeriodOption(
        value: 2,
        label: l10n.month,
        icon: Icons.calendar_month_rounded,
      ),
      AnalyticsPeriodOption(
        value: 3,
        label: l10n.year,
        icon: Icons.event_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnalyticsPeriodPill(
                  option: option,
                  isSelected: option.value == selectedPeriod,
                  colorScheme: colorScheme,
                  onTap: () => onSelectionChanged(option.value),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
