import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Medication Bar Chart Widget
/// Shows adherence rate per medication
class MedicationBarChart extends ConsumerWidget {
  const MedicationBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ref
        .watch(medicationInsightsProvider)
        .when(
          data: (insights) {
            if (insights.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      l10n.noMedicationDataAvailable,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }

            // Take top 5 medications
            final topInsights = insights.take(5).toList();

            return Card(
              margin: const EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bar_chart,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.adherenceByMedication,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final chartHeight = constraints.maxWidth < 360
                            ? 180.0
                            : 250.0;
                        return SizedBox(
                          height: chartHeight,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (group) =>
                                      colorScheme.inverseSurface,
                                  tooltipPadding: const EdgeInsets.all(8),
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final insight = topInsights[group.x];
                                    return BarTooltipItem(
                                      '${insight.medicationName}\n',
                                      TextStyle(
                                        color: colorScheme.onInverseSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${rod.toY.toStringAsFixed(1)}%\n',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '${insight.takenDoses}/${insight.totalDoses} doses',
                                          style: TextStyle(
                                            color: colorScheme.onInverseSurface
                                                .withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(),
                                topTitles: const AxisTitles(),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= 0 &&
                                          value.toInt() < topInsights.length) {
                                        final name = topInsights[value.toInt()]
                                            .medicationName;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            name.length > 10
                                                ? '${name.substring(0, 10)}...'
                                                : name,
                                            style: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 25,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '${value.toInt()}%',
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(
                                    color: colorScheme.outline,
                                  ),
                                  left: BorderSide(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ),
                              barGroups: topInsights.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final insight = entry.value;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: insight.adherenceRate,
                                      color: _getAdherenceColor(
                                        insight.adherenceRate,
                                        colorScheme,
                                      ),
                                      width: 30,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                              gridData: FlGridData(
                                drawVerticalLine: false,
                                horizontalInterval: 25,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: colorScheme.outlineVariant,
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l10n.errorLoadingChart(err.toString())),
            ),
          ),
        );
  }

  Color _getAdherenceColor(double percentage, ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    if (percentage >= 80)
      return isDark ? const Color(0xFF66BB6A) : Colors.green;
    if (percentage >= 50)
      return isDark ? const Color(0xFFFFA726) : Colors.orange;
    return isDark ? const Color(0xFFEF5350) : Colors.red;
  }
}
