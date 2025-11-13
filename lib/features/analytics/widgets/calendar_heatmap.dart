import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';

/// Calendar Heatmap Widget
/// Shows daily adherence as a GitHub-style heatmap
class CalendarHeatmap extends ConsumerWidget {
  const CalendarHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<TrendDataPoint>>(
      future: ref.read(analyticsProvider).getAdherenceTrend(30),
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

        final trendData = snapshot.data ?? [];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '30-Day Adherence Heatmap',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildHeatmap(trendData, colorScheme),
                const SizedBox(height: 16),
                _buildLegend(colorScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeatmap(List<TrendDataPoint> data, ColorScheme colorScheme) {
    // Group into weeks (7 days per row)
    final weeks = <List<TrendDataPoint>>[];
    for (var i = 0; i < data.length; i += 7) {
      final end = (i + 7 < data.length) ? i + 7 : data.length;
      weeks.add(data.sublist(i, end));
    }

    return Column(
      children: weeks.map((week) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: week.map((day) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Tooltip(
                    message: '${DateFormat('MMM d').format(day.date)}\n'
                        '${day.adherencePercentage.toStringAsFixed(1)}% adherence\n'
                        '${day.takenCount}/${day.totalCount} doses',
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: _getHeatmapColor(day.adherencePercentage, colorScheme),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        _LegendBox(color: colorScheme.surfaceContainerHighest),
        const SizedBox(width: 4),
        _LegendBox(color: Colors.red.withOpacity(0.3)),
        const SizedBox(width: 4),
        _LegendBox(color: Colors.orange.withOpacity(0.5)),
        const SizedBox(width: 4),
        _LegendBox(color: Colors.green.withOpacity(0.5)),
        const SizedBox(width: 4),
        const _LegendBox(color: Colors.green),
        const SizedBox(width: 8),
        Text(
          'More',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getHeatmapColor(double percentage, ColorScheme colorScheme) {
    if (percentage == 0) return colorScheme.surfaceContainerHighest;
    if (percentage < 25) return Colors.red.withOpacity(0.3);
    if (percentage < 50) return Colors.orange.withOpacity(0.5);
    if (percentage < 80) return Colors.green.withOpacity(0.5);
    return Colors.green;
  }
}

class _LegendBox extends StatelessWidget {

  const _LegendBox({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
