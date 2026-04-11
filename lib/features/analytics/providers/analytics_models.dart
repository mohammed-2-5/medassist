class AdherenceStats {
  AdherenceStats({
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
    required this.skippedDoses,
    required this.snoozedDoses,
  }) : adherencePercentage = totalDoses > 0
           ? (takenDoses / totalDoses * 100)
           : 0.0;

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

  StreakInfo.empty() : currentStreak = 0, bestStreak = 0, lastTakenDate = null;

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

/// Hourly adherence data for heatmap.
class HourlyAdherenceData {
  HourlyAdherenceData({
    required this.hour,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
  }) : adherencePercentage = totalDoses > 0
           ? (takenDoses / totalDoses * 100)
           : 0.0;

  final int hour; // 0-23
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final double adherencePercentage;
}
