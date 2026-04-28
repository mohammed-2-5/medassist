import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// 30-day adherence heatmap. Each cell = one day (oldest → today).
///
/// Color rules per day:
/// - all taken: cs.primary
/// - some taken, some missed/skipped: cs.tertiary
/// - all missed: cs.error
/// - no dose scheduled: cs.surfaceContainerHighest (muted)
class MedicationHistoryHeatmap extends StatelessWidget {
  const MedicationHistoryHeatmap({required this.history, super.key});

  final List<DoseHistoryData> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final byDay = <DateTime, List<DoseHistoryData>>{};
    for (final h in history) {
      final key = DateTime(
        h.scheduledDate.year,
        h.scheduledDate.month,
        h.scheduledDate.day,
      );
      byDay.putIfAbsent(key, () => []).add(h);
    }

    final days = List.generate(
      30,
      (i) => today.subtract(Duration(days: 29 - i)),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.last30Days,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const cols = 10;
              const gap = 4.0;
              final cell = (constraints.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final day in days)
                    _HeatCell(
                      size: cell,
                      color: _colorFor(byDay[day] ?? const [], cs),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _Legend(cs: cs, theme: theme, l10n: l10n),
        ],
      ),
    );
  }

  Color _colorFor(List<DoseHistoryData> day, ColorScheme cs) {
    if (day.isEmpty) {
      return cs.surfaceContainerHighest.withValues(alpha: 0.8);
    }
    final taken = day.where((h) => h.status == 'taken').length;
    final missed = day
        .where((h) => h.status == 'missed' || h.status == 'skipped')
        .length;
    if (taken == day.length) return cs.primary;
    if (missed == day.length) return cs.error;
    return cs.tertiary;
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.cs, required this.theme, required this.l10n});

  final ColorScheme cs;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _LegendItem(color: cs.primary, label: l10n.taken, theme: theme),
        _LegendItem(color: cs.tertiary, label: l10n.partial, theme: theme),
        _LegendItem(color: cs.error, label: l10n.missed, theme: theme),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.theme,
  });

  final Color color;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
