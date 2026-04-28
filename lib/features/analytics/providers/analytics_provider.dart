import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/utils/streak_utils.dart';
import 'package:med_assist/features/analytics/providers/analytics_computation_utils.dart';
import 'package:med_assist/features/analytics/providers/analytics_models.dart';

export 'package:med_assist/features/analytics/providers/analytics_models.dart';

/// Analytics service — all DB calls go through AppDatabase, no direct table access.
class AnalyticsNotifier {
  AnalyticsNotifier(this._database);

  final AppDatabase _database;

  Future<AdherenceStats> getAdherenceStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final stats = await _database.getAdherenceStats(startDate, endDate);
      final taken = stats['taken'] ?? 0;
      final skipped = stats['skipped'] ?? 0;
      final missed = stats['missed'] ?? 0;
      final snoozed = stats['snoozed'] ?? 0;
      return AdherenceStats(
        totalDoses: taken + skipped + missed + snoozed,
        takenDoses: taken,
        missedDoses: missed,
        skippedDoses: skipped,
        snoozedDoses: snoozed,
      );
    } catch (e) {
      debugPrint('Error getting adherence stats: $e');
      return AdherenceStats.empty();
    }
  }

  Future<AdherenceStats> getTodayAdherence() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return getAdherenceStats(start, start.add(const Duration(days: 1)));
  }

  Future<AdherenceStats> getWeekAdherence() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return getAdherenceStats(
      DateTime(weekStart.year, weekStart.month, weekStart.day),
      now,
    );
  }

  Future<AdherenceStats> getMonthAdherence() async {
    final now = DateTime.now();
    return getAdherenceStats(DateTime(now.year, now.month), now);
  }

  Future<AdherenceStats> getYearAdherence() async {
    final now = DateTime.now();
    return getAdherenceStats(DateTime(now.year), now);
  }

  Future<StreakInfo> getStreakInfo() async {
    try {
      final allHistory = await _database.getAllDoseHistory();
      if (allHistory.isEmpty) return StreakInfo.empty();

      final lastTaken = allHistory
          .where((d) => d.status == 'taken')
          .map((d) => d.actualTime ?? d.scheduledDate)
          .fold<DateTime?>(
            null,
            (prev, curr) => prev == null || curr.isAfter(prev) ? curr : prev,
          );

      return StreakInfo(
        currentStreak: StreakUtils.currentStreak(allHistory),
        bestStreak: StreakUtils.bestStreak(allHistory),
        lastTakenDate: lastTaken,
      );
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      return StreakInfo.empty();
    }
  }

  Future<List<MedicationInsight>> getMedicationInsights() async {
    try {
      final medications = await _database.getAllMedications();
      final allHistory = await _database.getAllDoseHistory();
      return AnalyticsComputationUtils.buildMedicationInsights(
        medications,
        allHistory,
      );
    } catch (e) {
      debugPrint('Error getting medication insights: $e');
      return [];
    }
  }

  Future<MedicationInsight?> getMostConsistentMedication() async {
    final insights = await getMedicationInsights();
    return insights.isNotEmpty ? insights.first : null;
  }

  Future<MedicationInsight?> getMostMissedMedication() async {
    final insights = await getMedicationInsights();
    if (insights.isEmpty) return null;
    return insights.reduce(
      (a, b) => a.adherenceRate < b.adherenceRate ? a : b,
    );
  }

  Future<List<TrendDataPoint>> getAdherenceTrend(int days) async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: days - 1),
      );
      final endDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));

      final allHistory = await _database.getAllDoseHistory();
      final rangeHistory = allHistory
          .where(
            (h) =>
                h.scheduledDate.isAfter(
                  startDate.subtract(const Duration(seconds: 1)),
                ) &&
                h.scheduledDate.isBefore(endDate),
          )
          .toList();

      return AnalyticsComputationUtils.buildTrendPoints(
        rangeHistory,
        days,
        now,
      );
    } catch (e) {
      debugPrint('Error getting adherence trend: $e');
      return [];
    }
  }

  Future<String> getBestTimeOfDay() async {
    try {
      final allHistory = await _database.getAllDoseHistory();
      if (allHistory.isEmpty) return 'No data';
      return AnalyticsComputationUtils.bestAdherencePeriod(allHistory);
    } catch (e) {
      debugPrint('Error calculating best time: $e');
      return 'No data';
    }
  }

  Future<String> exportAdherenceCSV(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final history = await _database.getAllDoseHistory();
      final medications = await _database.getAllMedications();
      final medMap = {for (final m in medications) m.id: m.medicineName};
      final filtered = history.where(
        (d) =>
            d.scheduledDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            d.scheduledDate.isBefore(endDate.add(const Duration(days: 1))),
      );
      return AnalyticsComputationUtils.buildCsv(filtered, medMap);
    } catch (e) {
      debugPrint('Error exporting CSV: $e');
      return 'Error exporting data';
    }
  }

  Future<List<HourlyAdherenceData>> getHourlyAdherenceData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allHistory = await _database.getAllDoseHistory();
      final filtered = allHistory
          .where(
            (dose) =>
                dose.scheduledDate.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                dose.scheduledDate.isBefore(
                  endDate.add(const Duration(days: 1)),
                ),
          )
          .toList();
      return AnalyticsComputationUtils.buildHourlyData(filtered);
    } catch (e) {
      debugPrint('Error getting hourly adherence data: $e');
      return List.generate(
        24,
        (hour) => HourlyAdherenceData(
          hour: hour,
          totalDoses: 0,
          takenDoses: 0,
          missedDoses: 0,
        ),
      );
    }
  }
}

final analyticsProvider = Provider<AnalyticsNotifier>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return AnalyticsNotifier(database);
});

final todayAdherenceProvider = FutureProvider<AdherenceStats>((ref) async {
  return ref.watch(analyticsProvider).getTodayAdherence();
});

final weekAdherenceProvider = FutureProvider<AdherenceStats>((ref) async {
  return ref.watch(analyticsProvider).getWeekAdherence();
});

final monthAdherenceProvider = FutureProvider<AdherenceStats>((ref) async {
  return ref.watch(analyticsProvider).getMonthAdherence();
});

final yearAdherenceProvider = FutureProvider<AdherenceStats>((ref) async {
  return ref.watch(analyticsProvider).getYearAdherence();
});

final streakInfoProvider = FutureProvider<StreakInfo>((ref) async {
  return ref.watch(analyticsProvider).getStreakInfo();
});

final medicationInsightsProvider = FutureProvider<List<MedicationInsight>>((
  ref,
) async {
  return ref.watch(analyticsProvider).getMedicationInsights();
});
