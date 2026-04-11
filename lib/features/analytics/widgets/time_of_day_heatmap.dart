import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/features/analytics/widgets/heatmap_hour_cell.dart';
import 'package:med_assist/features/analytics/widgets/heatmap_legend.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Time-of-Day Heatmap Widget
/// Shows adherence rates for each hour of the day (0-23)
/// Helps identify problematic times when doses are frequently missed
class TimeOfDayHeatmap extends ConsumerWidget {

  const TimeOfDayHeatmap({
    super.key,
    this.startDate,
    this.endDate,
  });
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    return FutureBuilder<List<HourlyAdherenceData>>(
      future: ref.read(analyticsProvider).getHourlyAdherenceData(start, end),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.all(0),
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l10n.errorLoadingHeatmap(snapshot.error.toString())),
            ),
          );
        }

        final hourlyData = snapshot.data ?? [];

        if (hourlyData.every((d) => d.totalDoses == 0)) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  l10n.noDoseDataForTimeAnalysis,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.all(0),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.timeOfDayAnalysis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.adherenceRateByHour,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Heatmap Grid
                _buildHeatmapGrid(context, hourlyData, colorScheme, theme),
                const SizedBox(height: 16),

                // Legend
                HeatmapLegend(theme: theme),
                const SizedBox(height: 16),

                // Insights
                _buildInsights(hourlyData, colorScheme, theme, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeatmapGrid(
    BuildContext context,
    List<HourlyAdherenceData> hourlyData,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    // Divide hours into 4 rows (6 hours each)
    return Column(
      children: List.generate(4, (rowIndex) {
        final startHour = rowIndex * 6;
        final rowData = hourlyData.sublist(startHour, startHour + 6);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: rowData.map((data) {
              return Expanded(
                child: HeatmapHourCell(
                  data: data,
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildInsights(
    List<HourlyAdherenceData> hourlyData,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final hoursWithData = hourlyData.where((d) => d.totalDoses > 0).toList();

    if (hoursWithData.isEmpty) {
      return const SizedBox.shrink();
    }

    hoursWithData.sort((a, b) => b.adherencePercentage.compareTo(a.adherencePercentage));

    final bestHour = hoursWithData.first;
    final worstHour = hoursWithData.last;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.insightsLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '✓ ${l10n.bestTimeInsight(formatHour(bestHour.hour), bestHour.adherencePercentage.toStringAsFixed(0))}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '⚠ ${l10n.needsAttentionInsight(formatHour(worstHour.hour), worstHour.adherencePercentage.toStringAsFixed(0))}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
