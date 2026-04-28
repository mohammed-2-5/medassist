import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// List of per-medication adherence insight tiles.
class AnalyticsMedicationInsights extends ConsumerWidget {
  const AnalyticsMedicationInsights({super.key});

  Color _getAdherenceColor(double percentage, ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    if (percentage >= 80)
      return isDark ? const Color(0xFF66BB6A) : Colors.green;
    if (percentage >= 50)
      return isDark ? const Color(0xFFFFA726) : Colors.orange;
    return isDark ? const Color(0xFFEF5350) : Colors.red;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ref
        .watch(medicationInsightsProvider)
        .when(
          data: (insights) {
            if (insights.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      l10n.noMedicationDataYet,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: insights.take(5).map((insight) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getAdherenceColor(
                        insight.adherenceRate,
                        colorScheme,
                      ).withOpacity(0.2),
                      child: Text(
                        '${insight.adherenceRate.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getAdherenceColor(
                            insight.adherenceRate,
                            colorScheme,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      insight.medicationName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      l10n.dosesTakenOf(insight.takenDoses, insight.totalDoses),
                    ),
                    trailing: Icon(
                      insight.adherenceRate >= 80
                          ? Icons.check_circle
                          : insight.adherenceRate >= 50
                          ? Icons.warning
                          : Icons.error,
                      color: _getAdherenceColor(
                        insight.adherenceRate,
                        colorScheme,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('${l10n.errorLoadingInsights}: $err'),
            ),
          ),
        );
  }
}
