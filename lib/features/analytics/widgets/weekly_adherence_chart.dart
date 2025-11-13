import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget displaying weekly adherence as a bar chart
class WeeklyAdherenceChart extends StatelessWidget {

  const WeeklyAdherenceChart({
    required this.dailyData,
    super.key,
  });
  final Map<String, Map<String, int>> dailyData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Convert dailyData to sorted list for chart
    final sortedDays = dailyData.keys.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, 'Taken', colorScheme.secondary),
                const SizedBox(width: 16),
                _buildLegendItem(context, 'Missed', colorScheme.error),
              ],
            ),
            const SizedBox(height: 24),

            // Chart
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => colorScheme.surfaceContainerHighest,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dayKey = sortedDays[group.x];
                        final dayData = dailyData[dayKey]!;
                        final label = rodIndex == 0 ? 'Taken' : 'Missed';
                        final value = rod.toY.toInt();

                        return BarTooltipItem(
                          '$dayKey\n$label: $value',
                          TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedDays.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                sortedDays[value.toInt()],
                                style: theme.textTheme.labelSmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      
                    ),
                    rightTitles: const AxisTitles(
                      
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outline),
                      left: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: _buildBarGroups(sortedDays, colorScheme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<String> sortedDays, ColorScheme colorScheme) {
    return List.generate(sortedDays.length, (index) {
      final dayKey = sortedDays[index];
      final dayData = dailyData[dayKey]!;
      final taken = dayData['taken']!.toDouble();
      final missed = dayData['missed']!.toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: taken,
            color: colorScheme.secondary,
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: missed,
            color: colorScheme.error,
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
        barsSpace: 4,
      );
    });
  }

  double _getMaxY() {
    var maxValue = 0.0;
    for (final dayData in dailyData.values) {
      final taken = dayData['taken']!.toDouble();
      final missed = dayData['missed']!.toDouble();
      final max = taken > missed ? taken : missed;
      if (max > maxValue) {
        maxValue = max;
      }
    }
    // Add 20% padding to the top
    return maxValue * 1.2 + 1;
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
