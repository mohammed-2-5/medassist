import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';

/// Unit tests for Analytics Data Models and Logic
/// Tests adherence calculations, streak tracking, and insights generation
void main() {
  group('AdherenceStats Model', () {
    test('Calculates adherence percentage correctly', () {
      final stats = AdherenceStats(
        totalDoses: 100,
        takenDoses: 85,
        missedDoses: 10,
        skippedDoses: 5,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, equals(85.0));
    });

    test('Handles zero total doses', () {
      final stats = AdherenceStats(
        totalDoses: 0,
        takenDoses: 0,
        missedDoses: 0,
        skippedDoses: 0,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, equals(0.0));
    });

    test('Perfect adherence shows 100%', () {
      final stats = AdherenceStats(
        totalDoses: 50,
        takenDoses: 50,
        missedDoses: 0,
        skippedDoses: 0,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, equals(100.0));
    });

    test('Zero adherence shows 0%', () {
      final stats = AdherenceStats(
        totalDoses: 30,
        takenDoses: 0,
        missedDoses: 20,
        skippedDoses: 10,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, equals(0.0));
    });

    test('Partial adherence calculates correctly', () {
      final stats = AdherenceStats(
        totalDoses: 10,
        takenDoses: 7,
        missedDoses: 2,
        skippedDoses: 1,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, equals(70.0));
    });

    test('Empty constructor creates zero stats', () {
      final stats = AdherenceStats.empty();

      expect(stats.totalDoses, equals(0));
      expect(stats.takenDoses, equals(0));
      expect(stats.missedDoses, equals(0));
      expect(stats.skippedDoses, equals(0));
      expect(stats.snoozedDoses, equals(0));
      expect(stats.adherencePercentage, equals(0.0));
    });

    test('Adherence percentage never exceeds 100', () {
      final stats = AdherenceStats(
        totalDoses: 10,
        takenDoses: 10,
        missedDoses: 0,
        skippedDoses: 0,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, lessThanOrEqualTo(100.0));
    });

    test('Adherence percentage is never negative', () {
      final stats = AdherenceStats(
        totalDoses: 5,
        takenDoses: 0,
        missedDoses: 5,
        skippedDoses: 0,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, greaterThanOrEqualTo(0.0));
    });

    test('Handles fractional percentages', () {
      final stats = AdherenceStats(
        totalDoses: 3,
        takenDoses: 2,
        missedDoses: 1,
        skippedDoses: 0,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, closeTo(66.67, 0.01));
    });

    test('Large numbers are handled correctly', () {
      final stats = AdherenceStats(
        totalDoses: 1000,
        takenDoses: 875,
        missedDoses: 100,
        skippedDoses: 25,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, equals(87.5));
    });

    test('Snoozed doses are counted in total', () {
      final stats = AdherenceStats(
        totalDoses: 20,
        takenDoses: 15,
        missedDoses: 2,
        skippedDoses: 1,
        snoozedDoses: 2,
      );

      expect(stats.totalDoses, equals(20));
      expect(stats.snoozedDoses, equals(2));
    });
  });

  group('StreakInfo Model', () {
    test('Creates streak info with valid data', () {
      final lastTaken = DateTime.now();
      final streak = StreakInfo(
        currentStreak: 5,
        bestStreak: 10,
        lastTakenDate: lastTaken,
      );

      expect(streak.currentStreak, equals(5));
      expect(streak.bestStreak, equals(10));
      expect(streak.lastTakenDate, equals(lastTaken));
    });

    test('Empty constructor creates zero streaks', () {
      final streak = StreakInfo.empty();

      expect(streak.currentStreak, equals(0));
      expect(streak.bestStreak, equals(0));
      expect(streak.lastTakenDate, isNull);
    });

    test('Handles null lastTakenDate', () {
      final streak = StreakInfo(
        currentStreak: 3,
        bestStreak: 8,
      );

      expect(streak.currentStreak, equals(3));
      expect(streak.bestStreak, equals(8));
      expect(streak.lastTakenDate, isNull);
    });

    test('Current streak can equal best streak', () {
      final streak = StreakInfo(
        currentStreak: 15,
        bestStreak: 15,
      );

      expect(streak.currentStreak, equals(streak.bestStreak));
    });

    test('Best streak is typically >= current streak', () {
      final streak = StreakInfo(
        currentStreak: 5,
        bestStreak: 20,
      );

      expect(streak.bestStreak, greaterThanOrEqualTo(streak.currentStreak));
    });

    test('Long streak numbers are supported', () {
      final streak = StreakInfo(
        currentStreak: 365,
        bestStreak: 500,
      );

      expect(streak.currentStreak, equals(365));
      expect(streak.bestStreak, equals(500));
    });
  });

  group('MedicationInsight Model', () {
    test('Creates insight with valid data', () {
      final insight = MedicationInsight(
        medicationId: 1,
        medicationName: 'Aspirin',
        adherenceRate: 85.5,
        totalDoses: 100,
        takenDoses: 85,
      );

      expect(insight.medicationId, equals(1));
      expect(insight.medicationName, equals('Aspirin'));
      expect(insight.adherenceRate, equals(85.5));
      expect(insight.totalDoses, equals(100));
      expect(insight.takenDoses, equals(85));
    });

    test('Handles perfect adherence', () {
      final insight = MedicationInsight(
        medicationId: 2,
        medicationName: 'Metformin',
        adherenceRate: 100,
        totalDoses: 50,
        takenDoses: 50,
      );

      expect(insight.adherenceRate, equals(100.0));
    });

    test('Handles zero adherence', () {
      final insight = MedicationInsight(
        medicationId: 3,
        medicationName: 'Vitamin D',
        adherenceRate: 0,
        totalDoses: 30,
        takenDoses: 0,
      );

      expect(insight.adherenceRate, equals(0.0));
    });

    test('Handles medication names with special characters', () {
      final insight = MedicationInsight(
        medicationId: 4,
        medicationName: 'Acetaminophen (Tylenol®)',
        adherenceRate: 75,
        totalDoses: 20,
        takenDoses: 15,
      );

      expect(insight.medicationName, contains('®'));
    });

    test('Handles long medication names', () {
      final insight = MedicationInsight(
        medicationId: 5,
        medicationName: 'Very Long Medication Name With Multiple Words And Details',
        adherenceRate: 80,
        totalDoses: 10,
        takenDoses: 8,
      );

      expect(insight.medicationName.length, greaterThan(20));
    });
  });

  group('TrendDataPoint Model', () {
    test('Creates trend point with valid data', () {
      final date = DateTime(2025, 1, 12);
      final point = TrendDataPoint(
        date: date,
        adherencePercentage: 85,
        takenCount: 17,
        totalCount: 20,
      );

      expect(point.date, equals(date));
      expect(point.adherencePercentage, equals(85.0));
      expect(point.takenCount, equals(17));
      expect(point.totalCount, equals(20));
    });

    test('Handles zero percentage', () {
      final point = TrendDataPoint(
        date: DateTime.now(),
        adherencePercentage: 0,
        takenCount: 0,
        totalCount: 10,
      );

      expect(point.adherencePercentage, equals(0.0));
    });

    test('Handles 100% percentage', () {
      final point = TrendDataPoint(
        date: DateTime.now(),
        adherencePercentage: 100,
        takenCount: 15,
        totalCount: 15,
      );

      expect(point.adherencePercentage, equals(100.0));
    });

    test('Multiple trend points for different dates', () {
      final points = [
        TrendDataPoint(
          date: DateTime(2025, 1, 10),
          adherencePercentage: 80,
          takenCount: 8,
          totalCount: 10,
        ),
        TrendDataPoint(
          date: DateTime(2025, 1, 11),
          adherencePercentage: 90,
          takenCount: 9,
          totalCount: 10,
        ),
        TrendDataPoint(
          date: DateTime(2025, 1, 12),
          adherencePercentage: 85,
          takenCount: 17,
          totalCount: 20,
        ),
      ];

      expect(points.length, equals(3));
      expect(points[0].date.day, equals(10));
      expect(points[1].date.day, equals(11));
      expect(points[2].date.day, equals(12));
    });
  });

  group('HourlyAdherenceData Model', () {
    test('Creates hourly data with valid input', () {
      final data = HourlyAdherenceData(
        hour: 8,
        totalDoses: 10,
        takenDoses: 8,
        missedDoses: 2,
      );

      expect(data.hour, equals(8));
      expect(data.totalDoses, equals(10));
      expect(data.takenDoses, equals(8));
      expect(data.missedDoses, equals(2));
      expect(data.adherencePercentage, equals(80.0));
    });

    test('Calculates adherence percentage correctly', () {
      final data = HourlyAdherenceData(
        hour: 12,
        totalDoses: 4,
        takenDoses: 3,
        missedDoses: 1,
      );

      expect(data.adherencePercentage, equals(75.0));
    });

    test('Handles zero total doses', () {
      final data = HourlyAdherenceData(
        hour: 0,
        totalDoses: 0,
        takenDoses: 0,
        missedDoses: 0,
      );

      expect(data.adherencePercentage, equals(0.0));
    });

    test('Handles perfect adherence', () {
      final data = HourlyAdherenceData(
        hour: 9,
        totalDoses: 5,
        takenDoses: 5,
        missedDoses: 0,
      );

      expect(data.adherencePercentage, equals(100.0));
    });

    test('Hour values range from 0-23', () {
      final morning = HourlyAdherenceData(
        hour: 0,
        totalDoses: 1,
        takenDoses: 1,
        missedDoses: 0,
      );

      final night = HourlyAdherenceData(
        hour: 23,
        totalDoses: 1,
        takenDoses: 1,
        missedDoses: 0,
      );

      expect(morning.hour, equals(0));
      expect(night.hour, equals(23));
      expect(morning.hour, greaterThanOrEqualTo(0));
      expect(night.hour, lessThanOrEqualTo(23));
    });

    test('Creates full day hourly data array', () {
      final hourlyData = List.generate(
        24,
        (hour) => HourlyAdherenceData(
          hour: hour,
          totalDoses: 2,
          takenDoses: 1,
          missedDoses: 1,
        ),
      );

      expect(hourlyData.length, equals(24));
      expect(hourlyData.first.hour, equals(0));
      expect(hourlyData.last.hour, equals(23));
    });

    test('Different doses at different hours', () {
      final morningRush = HourlyAdherenceData(
        hour: 8,
        totalDoses: 20,
        takenDoses: 18,
        missedDoses: 2,
      );

      final midday = HourlyAdherenceData(
        hour: 13,
        totalDoses: 5,
        takenDoses: 3,
        missedDoses: 2,
      );

      expect(morningRush.totalDoses, greaterThan(midday.totalDoses));
      expect(morningRush.adherencePercentage, equals(90.0));
      expect(midday.adherencePercentage, equals(60.0));
    });

    test('Handles zero adherence for specific hour', () {
      final data = HourlyAdherenceData(
        hour: 15,
        totalDoses: 3,
        takenDoses: 0,
        missedDoses: 3,
      );

      expect(data.adherencePercentage, equals(0.0));
    });
  });

  group('Data Models Edge Cases', () {
    test('AdherenceStats with all missed doses', () {
      final stats = AdherenceStats(
        totalDoses: 15,
        takenDoses: 0,
        missedDoses: 15,
        skippedDoses: 0,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, equals(0.0));
      expect(stats.missedDoses, equals(stats.totalDoses));
    });

    test('AdherenceStats with all skipped doses', () {
      final stats = AdherenceStats(
        totalDoses: 10,
        takenDoses: 0,
        missedDoses: 0,
        skippedDoses: 10,
        snoozedDoses: 0,
      );

      expect(stats.adherencePercentage, equals(0.0));
      expect(stats.skippedDoses, equals(stats.totalDoses));
    });

    test('AdherenceStats with mixed status doses', () {
      final stats = AdherenceStats(
        totalDoses: 100,
        takenDoses: 70,
        missedDoses: 15,
        skippedDoses: 10,
        snoozedDoses: 5,
      );

      expect(stats.totalDoses, equals(100));
      expect(
        stats.takenDoses + stats.missedDoses + stats.skippedDoses + stats.snoozedDoses,
        equals(stats.totalDoses),
      );
    });

    test('StreakInfo with very long streaks', () {
      final streak = StreakInfo(
        currentStreak: 1000,
        bestStreak: 1500,
      );

      expect(streak.currentStreak, equals(1000));
      expect(streak.bestStreak, equals(1500));
    });

    test('MedicationInsight with decimal adherence rates', () {
      final insight = MedicationInsight(
        medicationId: 1,
        medicationName: 'Test Med',
        adherenceRate: 83.33333,
        totalDoses: 6,
        takenDoses: 5,
      );

      expect(insight.adherenceRate, closeTo(83.33, 0.01));
    });

    test('TrendDataPoint with past dates', () {
      final oldDate = DateTime(2020);
      final point = TrendDataPoint(
        date: oldDate,
        adherencePercentage: 75,
        takenCount: 3,
        totalCount: 4,
      );

      expect(point.date.isBefore(DateTime.now()), isTrue);
    });

    test('TrendDataPoint with future dates', () {
      final futureDate = DateTime(2030, 12, 31);
      final point = TrendDataPoint(
        date: futureDate,
        adherencePercentage: 0,
        takenCount: 0,
        totalCount: 0,
      );

      expect(point.date.isAfter(DateTime.now()), isTrue);
    });

    test('Hourly data for midnight hour', () {
      final midnight = HourlyAdherenceData(
        hour: 0,
        totalDoses: 3,
        takenDoses: 2,
        missedDoses: 1,
      );

      expect(midnight.hour, equals(0));
      expect(midnight.adherencePercentage, closeTo(66.67, 0.01));
    });

    test('Hourly data for last hour of day', () {
      final lastHour = HourlyAdherenceData(
        hour: 23,
        totalDoses: 2,
        takenDoses: 2,
        missedDoses: 0,
      );

      expect(lastHour.hour, equals(23));
      expect(lastHour.adherencePercentage, equals(100.0));
    });
  });

  group('Data Models Consistency', () {
    test('AdherenceStats percentage matches taken/total ratio', () {
      final stats = AdherenceStats(
        totalDoses: 50,
        takenDoses: 40,
        missedDoses: 10,
        skippedDoses: 0,
        snoozedDoses: 0,
      );

      final expectedPercentage = (stats.takenDoses / stats.totalDoses) * 100;
      expect(stats.adherencePercentage, equals(expectedPercentage));
    });

    test('HourlyAdherenceData percentage matches taken/total ratio', () {
      final data = HourlyAdherenceData(
        hour: 10,
        totalDoses: 8,
        takenDoses: 6,
        missedDoses: 2,
      );

      final expectedPercentage = (data.takenDoses / data.totalDoses) * 100;
      expect(data.adherencePercentage, equals(expectedPercentage));
    });

    test('Multiple AdherenceStats with same data have same percentage', () {
      final stats1 = AdherenceStats(
        totalDoses: 10,
        takenDoses: 7,
        missedDoses: 3,
        skippedDoses: 0,
        snoozedDoses: 0,
      );

      final stats2 = AdherenceStats(
        totalDoses: 10,
        takenDoses: 7,
        missedDoses: 3,
        skippedDoses: 0,
        snoozedDoses: 0,
      );

      expect(stats1.adherencePercentage, equals(stats2.adherencePercentage));
    });

    test('Adherence percentage is consistent across models', () {
      // AdherenceStats
      final stats = AdherenceStats(
        totalDoses: 20,
        takenDoses: 16,
        missedDoses: 4,
        skippedDoses: 0,
        snoozedDoses: 0,
      );

      // HourlyAdherenceData with same ratio
      final hourly = HourlyAdherenceData(
        hour: 9,
        totalDoses: 20,
        takenDoses: 16,
        missedDoses: 4,
      );

      // MedicationInsight with same ratio
      final insight = MedicationInsight(
        medicationId: 1,
        medicationName: 'Test',
        adherenceRate: 80,
        totalDoses: 20,
        takenDoses: 16,
      );

      expect(stats.adherencePercentage, equals(80.0));
      expect(hourly.adherencePercentage, equals(80.0));
      expect(insight.adherenceRate, equals(80.0));
    });
  });
}
