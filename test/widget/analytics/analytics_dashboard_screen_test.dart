import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/features/analytics/screens/analytics_dashboard_screen.dart';

import '../helpers/widget_test_helpers.dart';

void main() {
  group('AnalyticsDashboardScreen', () {
    testWidgets('renders key sections across common breakpoints', (
      tester,
    ) async {
      for (final device in TestDeviceConfig.defaults) {
        await pumpAppWidget(
          tester,
          const AnalyticsDashboardScreen(),
          device: device,
          overrides: _buildAnalyticsOverrides(),
        );

        expect(
          tester.takeException(),
          isNull,
          reason: 'No overflow on ${device.name}',
        );
        expect(find.textContaining('Trends'), findsWidgets);
        expect(find.textContaining('Insights'), findsWidgets);
        expect(find.textContaining('Time-of-Day Analysis'), findsWidgets);
        expect(find.textContaining('Adherence by Medication'), findsWidgets);
      }
    });

    testWidgets('shows adherence stats and streak copy', (tester) async {
      await pumpAppWidget(
        tester,
        const AnalyticsDashboardScreen(),
        overrides: _buildAnalyticsOverrides(),
      );

      expect(find.textContaining('Adherence'), findsWidgets);
      expect(find.textContaining('Streak'), findsWidgets);
      expect(find.byIcon(Icons.pie_chart), findsWidgets);
      expect(find.byIcon(Icons.calendar_today), findsWidgets);
    });
  });
}

List<Override> _buildAnalyticsOverrides() {
  final fakeAnalytics = _FakeAnalyticsNotifier();
  final stats = TestDataFactory.adherenceStats(
    totalDoses: 20,
    takenDoses: 16,
    missedDoses: 2,
    snoozedDoses: 1,
  );

  final streak = StreakInfo(
    currentStreak: 7,
    bestStreak: 15,
    lastTakenDate: DateTime.now().subtract(const Duration(hours: 6)),
  );

  final insights = [
    MedicationInsight(
      medicationId: 1,
      medicationName: 'Aspirin',
      adherenceRate: 92,
      totalDoses: 12,
      takenDoses: 11,
    ),
    MedicationInsight(
      medicationId: 2,
      medicationName: 'Vitamin D',
      adherenceRate: 80,
      totalDoses: 10,
      takenDoses: 8,
    ),
  ];

  return [
    analyticsProvider.overrideWith((ref) => fakeAnalytics),
    todayAdherenceProvider.overrideWith((ref) async => stats),
    weekAdherenceProvider.overrideWith((ref) async => stats),
    monthAdherenceProvider.overrideWith((ref) async => stats),
    yearAdherenceProvider.overrideWith((ref) async => stats),
    streakInfoProvider.overrideWith((ref) async => streak),
    medicationInsightsProvider.overrideWith((ref) async => insights),
  ];
}

class _FakeAnalyticsNotifier extends AnalyticsNotifier {
  _FakeAnalyticsNotifier()
    : super(
        AppDatabase.forTesting(NativeDatabase.memory()),
      );

  @override
  Future<List<TrendDataPoint>> getAdherenceTrend(int days) async {
    final start = DateTime(2024);
    return List.generate(
      days,
      (index) => TrendDataPoint(
        date: start.add(Duration(days: index)),
        adherencePercentage: 60 + (index % 5) * 5,
        takenCount: 3,
        totalCount: 4,
      ),
    );
  }

  @override
  Future<List<HourlyAdherenceData>> getHourlyAdherenceData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return TestDataFactory.hourlyAdherenceSeries(peakPercentage: 90);
  }
}
