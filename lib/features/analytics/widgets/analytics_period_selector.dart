import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// M3 SegmentedButton selector for analytics time period.
///
/// Periods: 0 = Today, 1 = Week, 2 = Month, 3 = Year. Custom (4) is set
/// externally via the date-range picker; this selector shows no explicit
/// Custom segment.
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
    final effective = selectedPeriod.clamp(0, 3);

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<int>(
        segments: [
          ButtonSegment(value: 0, label: Text(l10n.today)),
          ButtonSegment(value: 1, label: Text(l10n.week)),
          ButtonSegment(value: 2, label: Text(l10n.month)),
          ButtonSegment(value: 3, label: Text(l10n.year)),
        ],
        selected: {effective},
        onSelectionChanged: (set) => onSelectionChanged(set.first),
        showSelectedIcon: false,
      ),
    );
  }
}
