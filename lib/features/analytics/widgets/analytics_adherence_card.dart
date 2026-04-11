import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/features/analytics/widgets/analytics_stat_item.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Card showing the adherence rate and dose breakdown for the selected period.
class AnalyticsAdherenceCard extends ConsumerWidget {
  const AnalyticsAdherenceCard({
    required this.selectedPeriod,
    super.key,
  });

  final int selectedPeriod;

  Color _getAdherenceColor(double percentage, ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    if (percentage >= 80) return isDark ? const Color(0xFF66BB6A) : Colors.green;
    if (percentage >= 50) return isDark ? const Color(0xFFFFA726) : Colors.orange;
    return isDark ? const Color(0xFFEF5350) : Colors.red;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final provider = selectedPeriod == 0
        ? todayAdherenceProvider
        : selectedPeriod == 1
            ? weekAdherenceProvider
            : selectedPeriod == 2
                ? monthAdherenceProvider
                : yearAdherenceProvider;

    return ref.watch(provider).when(
          data: (stats) => Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.adherenceRate,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getAdherenceColor(
                                    stats.adherencePercentage, colorScheme)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${stats.adherencePercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getAdherenceColor(
                                  stats.adherencePercentage, colorScheme),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: stats.adherencePercentage / 100,
                      minHeight: 12,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        _getAdherenceColor(
                            stats.adherencePercentage, colorScheme),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AnalyticsStatItem(
                          label: l10n.taken,
                          value: stats.takenDoses.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: AnalyticsStatItem(
                          label: l10n.missed,
                          value: stats.missedDoses.toString(),
                          icon: Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                      Expanded(
                        child: AnalyticsStatItem(
                          label: l10n.skipped,
                          value: stats.skippedDoses.toString(),
                          icon: Icons.remove_circle,
                          color: Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: AnalyticsStatItem(
                          label: l10n.total,
                          value: stats.totalDoses.toString(),
                          icon: Icons.medication,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('${l10n.errorLoadingStats}: $err'),
            ),
          ),
        );
  }
}
