import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/features/analytics/providers/analytics_providers.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Adherence Line Chart Widget
/// Shows adherence trend over the last 7 days
class AdherenceLineChart extends ConsumerWidget {
  const AdherenceLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final trendAsync = ref.watch(adherenceTrend7Provider);

    return trendAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(l10n.errorLoadingTrend(e.toString())),
        ),
      ),
      data: (trendData) {
        if (trendData.isEmpty) {
          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  l10n.noTrendDataAvailable,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          );
        }
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.adherenceTrendChart,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final chartHeight =
                        constraints.maxWidth < 360 ? 160.0 : 200.0;
                    return SizedBox(
                      height: chartHeight,
                      child: LineChart(
                        _buildChartData(trendData, colorScheme),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  LineChartData _buildChartData(
    List<TrendDataPoint> trendData,
    ColorScheme colorScheme,
  ) {
    return LineChartData(
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (_) => FlLine(
          color: colorScheme.outlineVariant,
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i >= 0 && i < trendData.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('E').format(trendData[i].date).substring(0, 1),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
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
            getTitlesWidget: (value, meta) => Text(
              '${value.toInt()}%',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline),
          left: BorderSide(color: colorScheme.outline),
        ),
      ),
      minX: 0,
      maxX: (trendData.length - 1).toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: trendData
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.adherencePercentage))
              .toList(),
          isCurved: true,
          color: colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 4,
              color: colorScheme.primary,
              strokeWidth: 2,
              strokeColor: colorScheme.surface,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: colorScheme.primary.withOpacity(0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => colorScheme.inverseSurface,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final i = spot.x.toInt();
              if (i >= 0 && i < trendData.length) {
                final data = trendData[i];
                return LineTooltipItem(
                  '${DateFormat('MMM d').format(data.date)}\n'
                  '${data.adherencePercentage.toStringAsFixed(1)}%\n'
                  '${data.takenCount}/${data.totalCount} doses',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }
}
