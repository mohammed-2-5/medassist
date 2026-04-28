import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/time_period_utils.dart';
import 'package:med_assist/features/analytics/providers/analytics_models.dart';

/// Pure computation helpers for analytics — no DB access, no Riverpod.
class AnalyticsComputationUtils {
  const AnalyticsComputationUtils._();

  /// Build trend points for [days] days ending at [now], from pre-filtered history.
  static List<TrendDataPoint> buildTrendPoints(
    List<DoseHistoryData> rangeHistory,
    int days,
    DateTime now,
  ) {
    final trendData = <TrendDataPoint>[];
    for (var i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final dayHistory = rangeHistory
          .where(
            (h) =>
                h.scheduledDate.isAfter(
                  startOfDay.subtract(const Duration(seconds: 1)),
                ) &&
                h.scheduledDate.isBefore(endOfDay),
          )
          .toList();

      final taken = dayHistory.where((h) => h.status == 'taken').length;
      final skipped = dayHistory.where((h) => h.status == 'skipped').length;
      final missed = dayHistory.where((h) => h.status == 'missed').length;
      final snoozed = dayHistory.where((h) => h.status == 'snoozed').length;
      final total = taken + skipped + missed + snoozed;

      trendData.add(
        TrendDataPoint(
          date: startOfDay,
          adherencePercentage: total > 0 ? (taken / total * 100) : 0.0,
          takenCount: taken,
          totalCount: total,
        ),
      );
    }
    return trendData;
  }

  /// Build 24-hour heatmap data from pre-filtered history.
  static List<HourlyAdherenceData> buildHourlyData(
    List<DoseHistoryData> filteredHistory,
  ) {
    final hourlyData = <int, Map<String, int>>{};
    for (var hour = 0; hour < 24; hour++) {
      hourlyData[hour] = {'total': 0, 'taken': 0, 'missed': 0};
    }
    for (final dose in filteredHistory) {
      final hour = dose.scheduledHour;
      hourlyData[hour]!['total'] = (hourlyData[hour]!['total'] ?? 0) + 1;
      if (dose.status == 'taken') {
        hourlyData[hour]!['taken'] = (hourlyData[hour]!['taken'] ?? 0) + 1;
      } else if (dose.status == 'missed') {
        hourlyData[hour]!['missed'] = (hourlyData[hour]!['missed'] ?? 0) + 1;
      }
    }
    return List.generate(
      24,
      (hour) => HourlyAdherenceData(
        hour: hour,
        totalDoses: hourlyData[hour]!['total']!,
        takenDoses: hourlyData[hour]!['taken']!,
        missedDoses: hourlyData[hour]!['missed']!,
      ),
    );
  }

  /// Build CSV string from pre-filtered dose history.
  static String buildCsv(
    Iterable<DoseHistoryData> filtered,
    Map<int, String> medMap,
  ) {
    final csv = StringBuffer();
    csv.writeln('Date,Time,Medication,Status,Notes');
    for (final dose in filtered) {
      final medName = medMap[dose.medicationId] ?? 'Unknown';
      final dateStr =
          '${dose.scheduledDate.year}-'
          '${dose.scheduledDate.month.toString().padLeft(2, '0')}-'
          '${dose.scheduledDate.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${dose.scheduledHour.toString().padLeft(2, '0')}:'
          '${dose.scheduledMinute.toString().padLeft(2, '0')}';
      final notes = dose.notes?.replaceAll(',', ';') ?? '';
      csv.writeln('$dateStr,$timeStr,$medName,${dose.status},$notes');
    }
    return csv.toString();
  }

  /// Find the time period with the highest adherence rate.
  static String bestAdherencePeriod(List<DoseHistoryData> allHistory) {
    final grouped = <String, List<DoseHistoryData>>{};
    for (final period in TimePeriodUtils.allPeriods) {
      grouped[period] = [];
    }
    for (final d in allHistory) {
      grouped[TimePeriodUtils.periodForHour(d.scheduledHour)]!.add(d);
    }
    var bestTime = TimePeriodUtils.morning;
    var bestRate = 0.0;
    for (final entry in grouped.entries) {
      if (entry.value.isEmpty) continue;
      final taken = entry.value.where((d) => d.status == 'taken').length;
      final rate = (taken / entry.value.length) * 100;
      if (rate > bestRate) {
        bestRate = rate;
        bestTime = entry.key;
      }
    }
    return bestTime;
  }

  /// Build medication insights from raw data.
  static List<MedicationInsight> buildMedicationInsights(
    List<Medication> medications,
    List<DoseHistoryData> allHistory,
  ) {
    final insights = <MedicationInsight>[];
    for (final med in medications) {
      final history = allHistory
          .where((d) => d.medicationId == med.id)
          .toList();
      if (history.isEmpty) continue;
      final taken = history.where((d) => d.status == 'taken').length;
      final total = history.length;
      insights.add(
        MedicationInsight(
          medicationId: med.id,
          medicationName: med.medicineName,
          adherenceRate: total > 0 ? (taken / total * 100) : 0.0,
          totalDoses: total,
          takenDoses: taken,
        ),
      );
    }
    insights.sort((a, b) => b.adherenceRate.compareTo(a.adherenceRate));
    return insights;
  }
}
