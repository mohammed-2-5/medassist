import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/utils/streak_utils.dart';
import 'package:med_assist/core/utils/time_period_utils.dart';
import 'package:med_assist/features/insights/models/health_insight.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Maps TimePeriodUtils period string to localized label.
String _localizedPeriod(String period, AppLocalizations l10n) {
  if (period == TimePeriodUtils.morning) return l10n.morning;
  if (period == TimePeriodUtils.afternoon) return l10n.afternoon;
  if (period == TimePeriodUtils.evening) return l10n.evening;
  return l10n.night;
}

/// Provider for adherence insights
// ignore: specify_nonobvious_property_types
final adherenceInsightsProvider =
    FutureProvider.family<List<HealthInsight>, AppLocalizations>((
      ref,
      l10n,
    ) async {
      final database = ref.read(appDatabaseProvider);
      final insights = <HealthInsight>[];

      try {
        // Calculate weekly adherence
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        final twoWeeksAgo = now.subtract(const Duration(days: 14));

        // Get dose history for last 2 weeks
        final allHistory = await database.getAllDoseHistory();

        // Filter for last week
        final lastWeekHistory = allHistory.where((dose) {
          return dose.scheduledDate.isAfter(weekAgo);
        }).toList();

        // Filter for previous week
        final previousWeekHistory = allHistory.where((dose) {
          return dose.scheduledDate.isAfter(twoWeeksAgo) &&
              dose.scheduledDate.isBefore(weekAgo);
        }).toList();

        if (lastWeekHistory.isNotEmpty) {
          // Calculate last week adherence
          final lastWeekTaken = lastWeekHistory
              .where((d) => d.status == 'taken')
              .length;
          final lastWeekTotal = lastWeekHistory.length;
          final lastWeekPercent = (lastWeekTaken / lastWeekTotal * 100).round();

          // Add weekly summary insight
          insights.add(
            HealthInsight(
              type: HealthInsightType.adherenceSummary,
              title: l10n.weeklyAdherenceInsightTitle,
              description: l10n.weeklyAdherenceInsightDesc(
                lastWeekPercent,
                lastWeekTaken,
                lastWeekTotal,
              ),
              value: lastWeekPercent.toDouble(),
              sentiment: lastWeekPercent >= 90
                  ? InsightSentiment.positive
                  : lastWeekPercent >= 70
                  ? InsightSentiment.neutral
                  : InsightSentiment.warning,
              icon: 'medication',
            ),
          );

          // Calculate trend if we have previous week data
          if (previousWeekHistory.isNotEmpty) {
            final prevWeekTaken = previousWeekHistory
                .where((d) => d.status == 'taken')
                .length;
            final prevWeekTotal = previousWeekHistory.length;
            final prevWeekPercent = (prevWeekTaken / prevWeekTotal * 100)
                .round();
            final change = lastWeekPercent - prevWeekPercent;

            if (change != 0) {
              insights.add(
                HealthInsight(
                  type: HealthInsightType.trend,
                  title: change > 0
                      ? l10n.improvingTrendTitle
                      : l10n.decliningTrendTitle,
                  description: change > 0
                      ? l10n.improvingTrendDesc(change.abs())
                      : l10n.decliningTrendDesc(change.abs()),
                  value: change.toDouble(),
                  sentiment: change > 0
                      ? InsightSentiment.positive
                      : change < 0
                      ? InsightSentiment.warning
                      : InsightSentiment.neutral,
                  icon: change > 0 ? 'trending_up' : 'trending_down',
                ),
              );
            }
          }
        }

        // Find best performing medication
        if (allHistory.isNotEmpty) {
          final medications = await database.getAllMedications();
          if (medications.isNotEmpty) {
            var bestMed = medications.first;
            var bestPercent = 0.0;

            for (final med in medications) {
              final medHistory = allHistory
                  .where((d) => d.medicationId == med.id)
                  .toList();
              if (medHistory.isNotEmpty) {
                final taken = medHistory
                    .where((d) => d.status == 'taken')
                    .length;
                final percent = taken / medHistory.length * 100;
                if (percent > bestPercent) {
                  bestPercent = percent;
                  bestMed = med;
                }
              }
            }

            if (bestPercent > 0) {
              insights.add(
                HealthInsight(
                  type: HealthInsightType.bestPerforming,
                  title: l10n.topMedicationTitle,
                  description: l10n.topMedicationDesc(
                    bestMed.medicineName,
                    bestPercent.round(),
                  ),
                  value: bestPercent,
                  sentiment: InsightSentiment.positive,
                  icon: 'star',
                ),
              );
            }
          }
        }

        // Calculate current streak
        if (allHistory.isNotEmpty) {
          final streak = StreakUtils.currentStreak(allHistory);

          if (streak > 0) {
            insights.add(
              HealthInsight(
                type: HealthInsightType.streak,
                title: l10n.streakDayTitle(streak),
                description: streak >= 7
                    ? l10n.streakAmazingDesc
                    : l10n.streakConsistencyDesc,
                value: streak.toDouble(),
                sentiment: InsightSentiment.positive,
                icon: 'local_fire_department',
              ),
            );
          }
        }

        // Find best time of day
        if (allHistory.isNotEmpty) {
          final timeGroups = {
            for (final p in TimePeriodUtils.allPeriods) p: 0,
          };
          final timeCounts = {
            for (final p in TimePeriodUtils.allPeriods) p: 0,
          };

          for (final dose in allHistory) {
            final period = TimePeriodUtils.periodForHour(dose.scheduledHour);
            timeCounts[period] = (timeCounts[period] ?? 0) + 1;
            if (dose.status == 'taken') {
              timeGroups[period] = (timeGroups[period] ?? 0) + 1;
            }
          }

          var bestTime = TimePeriodUtils.morning;
          var bestPercent = 0.0;

          for (final entry in timeGroups.entries) {
            final count = timeCounts[entry.key] ?? 1;
            final percent = entry.value / count * 100;
            if (percent > bestPercent) {
              bestPercent = percent;
              bestTime = entry.key;
            }
          }

          if (bestPercent > 0) {
            insights.add(
              HealthInsight(
                type: HealthInsightType.bestTime,
                title: l10n.bestTimeTitle,
                description: l10n.bestTimeDesc(
                  _localizedPeriod(bestTime, l10n),
                  bestPercent.round(),
                ),
                value: bestPercent,
                sentiment: InsightSentiment.neutral,
                icon: 'schedule',
              ),
            );
          }
        }

        // Add motivational message if adherence is low
        if (lastWeekHistory.isNotEmpty) {
          final lastWeekTaken = lastWeekHistory
              .where((d) => d.status == 'taken')
              .length;
          final lastWeekTotal = lastWeekHistory.length;
          final lastWeekPercent = (lastWeekTaken / lastWeekTotal * 100).round();

          if (lastWeekPercent >= 90) {
            insights.add(
              HealthInsight(
                type: HealthInsightType.motivation,
                title: l10n.excellentAdherenceInsightTitle,
                description: l10n.excellentAdherenceInsightDesc(
                  lastWeekPercent,
                ),
                value: lastWeekPercent.toDouble(),
                sentiment: InsightSentiment.positive,
                icon: 'star',
              ),
            );
          } else if (lastWeekPercent < 70) {
            insights.add(
              HealthInsight(
                type: HealthInsightType.motivation,
                title: l10n.needsImprovementTitle,
                description: l10n.needsImprovementInsightDesc(lastWeekPercent),
                value: lastWeekPercent.toDouble(),
                sentiment: InsightSentiment.warning,
                icon: 'lightbulb',
              ),
            );
          }
        }
      } catch (e) {
        // If error, return empty insights
        return [];
      }

      return insights;
    });
