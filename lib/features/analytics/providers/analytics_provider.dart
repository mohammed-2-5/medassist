import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';

/// Analytics data models

class AdherenceStats {

  AdherenceStats({
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
    required this.skippedDoses,
    required this.snoozedDoses,
  }) : adherencePercentage = totalDoses > 0 ? (takenDoses / totalDoses * 100) : 0.0;

  AdherenceStats.empty()
      : totalDoses = 0,
        takenDoses = 0,
        missedDoses = 0,
        skippedDoses = 0,
        snoozedDoses = 0,
        adherencePercentage = 0.0;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final int skippedDoses;
  final int snoozedDoses;
  final double adherencePercentage;
}

class StreakInfo {

  StreakInfo({
    required this.currentStreak,
    required this.bestStreak,
    this.lastTakenDate,
  });

  StreakInfo.empty()
      : currentStreak = 0,
        bestStreak = 0,
        lastTakenDate = null;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastTakenDate;
}

class MedicationInsight {

  MedicationInsight({
    required this.medicationId,
    required this.medicationName,
    required this.adherenceRate,
    required this.totalDoses,
    required this.takenDoses,
  });
  final int medicationId;
  final String medicationName;
  final double adherenceRate;
  final int totalDoses;
  final int takenDoses;
}

class TrendDataPoint {

  TrendDataPoint({
    required this.date,
    required this.adherencePercentage,
    required this.takenCount,
    required this.totalCount,
  });
  final DateTime date;
  final double adherencePercentage;
  final int takenCount;
  final int totalCount;
}

/// Hourly adherence data for heatmap
class HourlyAdherenceData {

  HourlyAdherenceData({
    required this.hour,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
  }) : adherencePercentage = totalDoses > 0 ? (takenDoses / totalDoses * 100) : 0.0;
  final int hour; // 0-23
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final double adherencePercentage;
}

/// Analytics Provider
class AnalyticsNotifier {
  AnalyticsNotifier(this._database);

  final AppDatabase _database;

  /// Get adherence statistics for a date range
  Future<AdherenceStats> getAdherenceStats(DateTime startDate, DateTime endDate) async {
    try {
      final stats = await _database.getAdherenceStats(startDate, endDate);

      final taken = stats['taken'] ?? 0;
      final skipped = stats['skipped'] ?? 0;
      final missed = stats['missed'] ?? 0;
      final snoozed = stats['snoozed'] ?? 0;
      final total = taken + skipped + missed + snoozed;

      return AdherenceStats(
        totalDoses: total,
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

  /// Get today's adherence
  Future<AdherenceStats> getTodayAdherence() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getAdherenceStats(startOfDay, endOfDay);
  }

  /// Get this week's adherence
  Future<AdherenceStats> getWeekAdherence() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return getAdherenceStats(startOfWeek, now);
  }

  /// Get this month's adherence
  Future<AdherenceStats> getMonthAdherence() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    return getAdherenceStats(monthStart, now);
  }

  /// Get this year's adherence
  Future<AdherenceStats> getYearAdherence() async {
    final now = DateTime.now();
    final yearStart = DateTime(now.year);
    return getAdherenceStats(yearStart, now);
  }

  /// Calculate current and best streak
  Future<StreakInfo> getStreakInfo() async {
    try {
      final allHistory = await _database.getAllDoseHistory();

      if (allHistory.isEmpty) {
        return StreakInfo.empty();
      }

      // Group doses by date
      final dosesByDate = <DateTime, List<DoseHistoryData>>{};
      for (final dose in allHistory) {
        final dateKey = DateTime(
          dose.scheduledDate.year,
          dose.scheduledDate.month,
          dose.scheduledDate.day,
        );
        dosesByDate.putIfAbsent(dateKey, () => []).add(dose);
      }

      // Calculate adherence for each day (100% if all doses taken)
      final dailyAdherence = <DateTime, bool>{};
      dosesByDate.forEach((date, doses) {
        final allTaken = doses.every((d) => d.status == 'taken');
        dailyAdherence[date] = allTaken;
      });

      // Sort dates
      final sortedDates = dailyAdherence.keys.toList()..sort((a, b) => b.compareTo(a));

      // Calculate current streak (from today backwards)
      var currentStreak = 0;
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      for (var i = 0; i < sortedDates.length; i++) {
        final date = sortedDates[i];
        final daysDiff = today.difference(date).inDays;

        if (daysDiff == i && dailyAdherence[date]! ?? false) {
          currentStreak++;
        } else if (daysDiff <= i) {
          break;
        }
      }

      // Calculate best streak
      var bestStreak = 0;
      var tempStreak = 0;
      DateTime? lastDate;

      for (final date in sortedDates.reversed) {
        if (dailyAdherence[date] ?? false) {
          if (lastDate == null || date.difference(lastDate).inDays == 1) {
            tempStreak++;
            bestStreak = tempStreak > bestStreak ? tempStreak : bestStreak;
          } else {
            tempStreak = 1;
          }
          lastDate = date;
        } else {
          tempStreak = 0;
        }
      }

      final lastTaken = allHistory
          .where((d) => d.status == 'taken')
          .map((d) => d.actualTime ?? d.scheduledDate)
          .fold<DateTime?>(null, (prev, curr) => prev == null || curr.isAfter(prev) ? curr : prev);

      return StreakInfo(
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        lastTakenDate: lastTaken,
      );
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      return StreakInfo.empty();
    }
  }

  /// Get medication insights (adherence per medication)
  Future<List<MedicationInsight>> getMedicationInsights() async {
    try {
      final medications = await _database.getAllMedications();
      final insights = <MedicationInsight>[];

      for (final med in medications) {
        final history = await _database.getDoseHistory(med.id);
        if (history.isEmpty) continue;

        final taken = history.where((d) => d.status == 'taken').length;
        final total = history.length;
        final rate = total > 0 ? (taken / total * 100) : 0.0;

        insights.add(MedicationInsight(
          medicationId: med.id,
          medicationName: med.medicineName,
          adherenceRate: rate,
          totalDoses: total,
          takenDoses: taken,
        ));
      }

      // Sort by adherence rate (descending)
      insights.sort((a, b) => b.adherenceRate.compareTo(a.adherenceRate));

      return insights;
    } catch (e) {
      debugPrint('Error getting medication insights: $e');
      return [];
    }
  }

  /// Get most consistent medication
  Future<MedicationInsight?> getMostConsistentMedication() async {
    final insights = await getMedicationInsights();
    return insights.isNotEmpty ? insights.first : null;
  }

  /// Get most missed medication
  Future<MedicationInsight?> getMostMissedMedication() async {
    final insights = await getMedicationInsights();
    if (insights.isEmpty) return null;

    // Sort by adherence rate (ascending) to get worst
    insights.sort((a, b) => a.adherenceRate.compareTo(b.adherenceRate));
    return insights.first;
  }

  /// Get adherence trend for last N days
  Future<List<TrendDataPoint>> getAdherenceTrend(int days) async {
    try {
      final now = DateTime.now();
      final trendData = <TrendDataPoint>[];

      for (var i = days - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final stats = await getAdherenceStats(startOfDay, endOfDay);

        trendData.add(TrendDataPoint(
          date: startOfDay,
          adherencePercentage: stats.adherencePercentage,
          takenCount: stats.takenDoses,
          totalCount: stats.totalDoses,
        ));
      }

      return trendData;
    } catch (e) {
      debugPrint('Error getting adherence trend: $e');
      return [];
    }
  }

  /// Get best time of day for adherence
  Future<String> getBestTimeOfDay() async {
    try {
      final allHistory = await _database.getAllDoseHistory();

      if (allHistory.isEmpty) return 'No data';

      // Group by time of day
      final morning = allHistory.where((d) => d.scheduledHour >= 6 && d.scheduledHour < 12);
      final afternoon = allHistory.where((d) => d.scheduledHour >= 12 && d.scheduledHour < 18);
      final evening = allHistory.where((d) => d.scheduledHour >= 18 && d.scheduledHour < 22);
      final night = allHistory.where((d) => d.scheduledHour >= 22 || d.scheduledHour < 6);

      // Calculate adherence for each period
      double calcRate(Iterable<DoseHistoryData> doses) {
        if (doses.isEmpty) return 0;
        final taken = doses.where((d) => d.status == 'taken').length;
        return (taken / doses.length) * 100;
      }

      final rates = {
        'Morning (6 AM - 12 PM)': calcRate(morning),
        'Afternoon (12 PM - 6 PM)': calcRate(afternoon),
        'Evening (6 PM - 10 PM)': calcRate(evening),
        'Night (10 PM - 6 AM)': calcRate(night),
      };

      // Find best time
      var bestTime = 'Morning (6 AM - 12 PM)';
      var bestRate = 0.0;

      rates.forEach((time, rate) {
        if (rate > bestRate) {
          bestRate = rate;
          bestTime = time;
        }
      });

      return bestTime;
    } catch (e) {
      debugPrint('Error calculating best time: $e');
      return 'No data';
    }
  }

  /// Export adherence data as CSV string
  Future<String> exportAdherenceCSV(DateTime startDate, DateTime endDate) async {
    try {
      final history = await _database.getAllDoseHistory();
      final filtered = history.where((d) =>
        d.scheduledDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
        d.scheduledDate.isBefore(endDate.add(const Duration(days: 1))));

      final csv = StringBuffer();
      csv.writeln('Date,Time,Medication,Status,Notes');

      for (final dose in filtered) {
        final medication = await _database.getMedicationById(dose.medicationId);
        final medName = medication?.medicineName ?? 'Unknown';
        final dateStr = '${dose.scheduledDate.year}-${dose.scheduledDate.month.toString().padLeft(2, '0')}-${dose.scheduledDate.day.toString().padLeft(2, '0')}';
        final timeStr = '${dose.scheduledHour.toString().padLeft(2, '0')}:${dose.scheduledMinute.toString().padLeft(2, '0')}';
        final notes = dose.notes?.replaceAll(',', ';') ?? '';

        csv.writeln('$dateStr,$timeStr,$medName,${dose.status},$notes');
      }

      return csv.toString();
    } catch (e) {
      debugPrint('Error exporting CSV: $e');
      return 'Error exporting data';
    }
  }

  /// Get hourly adherence data for heatmap (0-23 hours)
  /// Returns data for the specified date range
  Future<List<HourlyAdherenceData>> getHourlyAdherenceData(DateTime startDate, DateTime endDate) async {
    try {
      final allHistory = await _database.getAllDoseHistory();

      // Filter history by date range
      final filteredHistory = allHistory.where((dose) {
        return dose.scheduledDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               dose.scheduledDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      // Group doses by hour (0-23)
      final hourlyData = <int, Map<String, int>>{};

      for (var hour = 0; hour < 24; hour++) {
        hourlyData[hour] = {'total': 0, 'taken': 0, 'missed': 0};
      }

      // Count doses for each hour
      for (final dose in filteredHistory) {
        final hour = dose.scheduledHour;
        hourlyData[hour]!['total'] = (hourlyData[hour]!['total'] ?? 0) + 1;

        if (dose.status == 'taken') {
          hourlyData[hour]!['taken'] = (hourlyData[hour]!['taken'] ?? 0) + 1;
        } else if (dose.status == 'missed') {
          hourlyData[hour]!['missed'] = (hourlyData[hour]!['missed'] ?? 0) + 1;
        }
      }

      // Convert to list of HourlyAdherenceData
      final result = <HourlyAdherenceData>[];
      for (var hour = 0; hour < 24; hour++) {
        result.add(HourlyAdherenceData(
          hour: hour,
          totalDoses: hourlyData[hour]!['total']!,
          takenDoses: hourlyData[hour]!['taken']!,
          missedDoses: hourlyData[hour]!['missed']!,
        ));
      }

      return result;
    } catch (e) {
      debugPrint('Error getting hourly adherence data: $e');
      return List.generate(24, (hour) => HourlyAdherenceData(
        hour: hour,
        totalDoses: 0,
        takenDoses: 0,
        missedDoses: 0,
      ));
    }
  }
}

/// Provider for analytics
final analyticsProvider = Provider<AnalyticsNotifier>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return AnalyticsNotifier(database);
});

/// Convenience providers for specific stats
final todayAdherenceProvider = FutureProvider<AdherenceStats>((ref) async {
  final analytics = ref.watch(analyticsProvider);
  return analytics.getTodayAdherence();
});

final weekAdherenceProvider = FutureProvider<AdherenceStats>((ref) async {
  final analytics = ref.watch(analyticsProvider);
  return analytics.getWeekAdherence();
});

final monthAdherenceProvider = FutureProvider<AdherenceStats>((ref) async {
  final analytics = ref.watch(analyticsProvider);
  return analytics.getMonthAdherence();
});

final yearAdherenceProvider = FutureProvider<AdherenceStats>((ref) async {
  final analytics = ref.watch(analyticsProvider);
  return analytics.getYearAdherence();
});

final streakInfoProvider = FutureProvider<StreakInfo>((ref) async {
  final analytics = ref.watch(analyticsProvider);
  return analytics.getStreakInfo();
});

final medicationInsightsProvider = FutureProvider<List<MedicationInsight>>((ref) async {
  final analytics = ref.watch(analyticsProvider);
  return analytics.getMedicationInsights();
});
