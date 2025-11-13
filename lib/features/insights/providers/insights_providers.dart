import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/insights/models/health_insight.dart';

/// Provider for adherence insights
final adherenceInsightsProvider = FutureProvider<List<HealthInsight>>((ref) async {
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
      final lastWeekTaken = lastWeekHistory.where((d) => d.status == 'taken').length;
      final lastWeekTotal = lastWeekHistory.length;
      final lastWeekPercent = (lastWeekTaken / lastWeekTotal * 100).round();

      // Add weekly summary insight
      insights.add(HealthInsight(
        type: HealthInsightType.adherenceSummary,
        title: 'Weekly Adherence',
        description: 'You took $lastWeekPercent% of your doses this week ($lastWeekTaken/$lastWeekTotal)',
        value: lastWeekPercent.toDouble(),
        sentiment: lastWeekPercent >= 90
            ? InsightSentiment.positive
            : lastWeekPercent >= 70
                ? InsightSentiment.neutral
                : InsightSentiment.warning,
        icon: 'medication',
      ));

      // Calculate trend if we have previous week data
      if (previousWeekHistory.isNotEmpty) {
        final prevWeekTaken = previousWeekHistory.where((d) => d.status == 'taken').length;
        final prevWeekTotal = previousWeekHistory.length;
        final prevWeekPercent = (prevWeekTaken / prevWeekTotal * 100).round();
        final change = lastWeekPercent - prevWeekPercent;

        if (change != 0) {
          insights.add(HealthInsight(
            type: HealthInsightType.trend,
            title: change > 0 ? 'Improving Trend 📈' : 'Declining Trend 📉',
            description: change > 0
                ? 'You improved by ${change.abs()}% compared to last week. Great progress!'
                : "You declined by ${change.abs()}% compared to last week. Let's get back on track!",
            value: change.toDouble(),
            sentiment: change > 0
                ? InsightSentiment.positive
                : change < 0
                    ? InsightSentiment.warning
                    : InsightSentiment.neutral,
            icon: change > 0 ? 'trending_up' : 'trending_down',
          ));
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
          final medHistory = allHistory.where((d) => d.medicationId == med.id).toList();
          if (medHistory.isNotEmpty) {
            final taken = medHistory.where((d) => d.status == 'taken').length;
            final percent = taken / medHistory.length * 100;
            if (percent > bestPercent) {
              bestPercent = percent;
              bestMed = med;
            }
          }
        }

        if (bestPercent > 0) {
          insights.add(HealthInsight(
            type: HealthInsightType.bestPerforming,
            title: 'Top Medication',
            description: '${bestMed.medicineName} has ${bestPercent.round()}% adherence - your most consistent medication!',
            value: bestPercent,
            sentiment: InsightSentiment.positive,
            icon: 'star',
          ));
        }
      }
    }

    // Calculate current streak
    if (allHistory.isNotEmpty) {
      var streak = 0;
      var currentDate = DateTime.now();
      final sortedHistory = allHistory.toList()
        ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

      for (var i = 0; i < 30 && i < sortedHistory.length; i++) {
        final dose = sortedHistory[i];
        final doseDate = DateTime(
          dose.scheduledDate.year,
          dose.scheduledDate.month,
          dose.scheduledDate.day,
        );
        final checkDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );

        if (doseDate == checkDate && dose.status == 'taken') {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else if (doseDate.isBefore(checkDate)) {
          break;
        }
      }

      if (streak > 0) {
        insights.add(HealthInsight(
          type: HealthInsightType.streak,
          title: '$streak-Day Streak! 🔥',
          description: streak >= 7
              ? "Amazing! You've been consistent for over a week!"
              : 'Keep it up! Consistency is key to better health.',
          value: streak.toDouble(),
          sentiment: InsightSentiment.positive,
          icon: 'local_fire_department',
        ));
      }
    }

    // Find best time of day
    if (allHistory.isNotEmpty) {
      final timeGroups = {
        'Morning (6 AM - 12 PM)': 0,
        'Afternoon (12 PM - 6 PM)': 0,
        'Evening (6 PM - 10 PM)': 0,
        'Night (10 PM - 6 AM)': 0,
      };

      final timeCounts = {
        'Morning (6 AM - 12 PM)': 0,
        'Afternoon (12 PM - 6 PM)': 0,
        'Evening (6 PM - 10 PM)': 0,
        'Night (10 PM - 6 AM)': 0,
      };

      for (final dose in allHistory) {
        final hour = dose.scheduledHour;
        String period;
        if (hour >= 6 && hour < 12) {
          period = 'Morning (6 AM - 12 PM)';
        } else if (hour >= 12 && hour < 18) {
          period = 'Afternoon (12 PM - 6 PM)';
        } else if (hour >= 18 && hour < 22) {
          period = 'Evening (6 PM - 10 PM)';
        } else {
          period = 'Night (10 PM - 6 AM)';
        }

        timeCounts[period] = (timeCounts[period] ?? 0) + 1;
        if (dose.status == 'taken') {
          timeGroups[period] = (timeGroups[period] ?? 0) + 1;
        }
      }

      var bestTime = 'Morning (6 AM - 12 PM)';
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
        insights.add(HealthInsight(
          type: HealthInsightType.bestTime,
          title: 'Best Time ⏰',
          description: 'Your most consistent time is $bestTime with ${bestPercent.round()}% adherence',
          value: bestPercent,
          sentiment: InsightSentiment.neutral,
          icon: 'schedule',
        ));
      }
    }

    // Add motivational message if adherence is low
    if (lastWeekHistory.isNotEmpty) {
      final lastWeekTaken = lastWeekHistory.where((d) => d.status == 'taken').length;
      final lastWeekTotal = lastWeekHistory.length;
      final lastWeekPercent = (lastWeekTaken / lastWeekTotal * 100).round();

      if (lastWeekPercent < 70) {
        insights.add(HealthInsight(
          type: HealthInsightType.motivation,
          title: 'Needs Improvement',
          description: 'Your adherence this week was $lastWeekPercent%. Try setting more reminders or adjusting your schedule to improve.',
          value: lastWeekPercent.toDouble(),
          sentiment: InsightSentiment.warning,
          icon: 'lightbulb',
        ));
      }
    }
  } catch (e) {
    // If error, return empty insights
    return [];
  }

  return insights;
});
