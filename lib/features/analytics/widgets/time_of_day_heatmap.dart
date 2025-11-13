import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';

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

    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    return FutureBuilder<List<HourlyAdherenceData>>(
      future: ref.read(analyticsProvider).getHourlyAdherenceData(start, end),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
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
              child: Text('Error loading heatmap: ${snapshot.error}'),
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
                  'No dose data available for time analysis',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          );
        }

        return Card(
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
                            'Time-of-Day Analysis',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Adherence rate by hour of day',
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
                _buildHeatmapGrid(hourlyData, colorScheme, theme),
                const SizedBox(height: 16),

                // Legend
                _buildLegend(colorScheme, theme),
                const SizedBox(height: 16),

                // Insights
                _buildInsights(hourlyData, colorScheme, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeatmapGrid(
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
                child: _buildHourCell(data, colorScheme, theme),
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildHourCell(
    HourlyAdherenceData data,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    // Color based on adherence rate
    final color = _getColorForAdherence(
      data.adherencePercentage,
      colorScheme,
      data.totalDoses > 0,
    );

    final hourStr = _formatHour(data.hour);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hourStr,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getTextColorForBackground(color),
            ),
          ),
          if (data.totalDoses > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${data.adherencePercentage.toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: _getTextColorForBackground(color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColorForAdherence(
    double percentage,
    ColorScheme colorScheme,
    bool hasData,
  ) {
    if (!hasData) {
      return colorScheme.surfaceContainerHighest.withOpacity(0.3);
    }

    if (percentage >= 90) {
      return Colors.green.shade400;
    } else if (percentage >= 75) {
      return Colors.lightGreen.shade300;
    } else if (percentage >= 60) {
      return Colors.amber.shade300;
    } else if (percentage >= 40) {
      return Colors.orange.shade400;
    } else {
      return Colors.red.shade400;
    }
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12AM';
    if (hour < 12) return '${hour}AM';
    if (hour == 12) return '12PM';
    return '${hour - 12}PM';
  }

  Widget _buildLegend(ColorScheme colorScheme, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green.shade400, '90%+', theme),
        const SizedBox(width: 8),
        _buildLegendItem(Colors.lightGreen.shade300, '75-89%', theme),
        const SizedBox(width: 8),
        _buildLegendItem(Colors.amber.shade300, '60-74%', theme),
        const SizedBox(width: 8),
        _buildLegendItem(Colors.orange.shade400, '40-59%', theme),
        const SizedBox(width: 8),
        _buildLegendItem(Colors.red.shade400, '<40%', theme),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildInsights(
    List<HourlyAdherenceData> hourlyData,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    // Find best and worst hours
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
                'Insights',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '✓ Best time: ${_formatHour(bestHour.hour)} (${bestHour.adherencePercentage.toStringAsFixed(0)}% adherence)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '⚠ Needs attention: ${_formatHour(worstHour.hour)} (${worstHour.adherencePercentage.toStringAsFixed(0)}% adherence)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
