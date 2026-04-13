import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Status Pie Chart Widget
/// Shows distribution of dose statuses
class StatusPieChart extends ConsumerWidget {
  const StatusPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ref.watch(monthAdherenceProvider).when(
          data: (stats) {
            if (stats.totalDoses == 0) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      l10n.noDoseDataThisMonth,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }

            final sections = <PieChartSectionData>[];

            final takenColor = colorScheme.brightness == Brightness.dark
                ? const Color(0xFF66BB6A) : Colors.green;
            final missedColor = colorScheme.brightness == Brightness.dark
                ? const Color(0xFFEF5350) : Colors.red;
            final skippedColor = colorScheme.brightness == Brightness.dark
                ? const Color(0xFFFFA726) : Colors.orange;
            final snoozedColor = colorScheme.brightness == Brightness.dark
                ? const Color(0xFF42A5F5) : Colors.blue;

            if (stats.takenDoses > 0) {
              sections.add(PieChartSectionData(
                color: takenColor,
                value: stats.takenDoses.toDouble(),
                title: '${stats.takenDoses}',
                radius: 100,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ));
            }

            if (stats.missedDoses > 0) {
              sections.add(PieChartSectionData(
                color: missedColor,
                value: stats.missedDoses.toDouble(),
                title: '${stats.missedDoses}',
                radius: 100,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ));
            }

            if (stats.skippedDoses > 0) {
              sections.add(PieChartSectionData(
                color: skippedColor,
                value: stats.skippedDoses.toDouble(),
                title: '${stats.skippedDoses}',
                radius: 100,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ));
            }

            if (stats.snoozedDoses > 0) {
              sections.add(PieChartSectionData(
                color: snoozedColor,
                value: stats.snoozedDoses.toDouble(),
                title: '${stats.snoozedDoses}',
                radius: 100,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ));
            }

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
                          Icons.pie_chart,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded( // 👈 يجبر النص يلتزم بالعرض المتاح
                          child: Text(
                            l10n.doseStatusDistribution,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final chartHeight = constraints.maxWidth < 360 ? 160.0 : 200.0;
                        return Center(
                          child: SizedBox(
                            height: chartHeight,
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                centerSpaceRadius: 0,
                                sectionsSpace: 2,
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Legend
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        if (stats.takenDoses > 0)
                          _LegendItem(
                            color: takenColor,
                            label: l10n.taken,
                            value: stats.takenDoses,
                          ),
                        if (stats.missedDoses > 0)
                          _LegendItem(
                            color: missedColor,
                            label: l10n.missed,
                            value: stats.missedDoses,
                          ),
                        if (stats.skippedDoses > 0)
                          _LegendItem(
                            color: skippedColor,
                            label: l10n.skipped,
                            value: stats.skippedDoses,
                          ),
                        if (stats.snoozedDoses > 0)
                          _LegendItem(
                            color: snoozedColor,
                            label: l10n.snooze,
                            value: stats.snoozedDoses,
                          ),
                      ],
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
}

class _LegendItem extends StatelessWidget {

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($value)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
