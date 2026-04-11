import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';
import 'package:med_assist/features/stock/screens/stock_overview_screen.dart';

import '../helpers/widget_test_helpers.dart';

void main() {
  group('StockOverviewScreen', () {
    testWidgets('shows empty state when no medications', (tester) async {
      await pumpAppWidget(
        tester,
        const StockOverviewScreen(),
        overrides: [
          medicationsStockProvider.overrideWith((ref) async => []),
          stockStatisticsProvider.overrideWith(
            (ref) async => {
              'total': 0,
              'critical': 0,
              'low': 0,
              'medium': 0,
              'good': 0,
              'expired': 0,
              'expiring_soon': 0,
            },
          ),
        ],
      );

      await tester.pump(const Duration(milliseconds: 10));

      expect(find.byKey(const Key('stock_empty_state_card')), findsOneWidget);
    });

    testWidgets('renders stock summary and cards', (tester) async {
      final mockStock = TestDataFactory.medicationStock(
        currentStock: 12,
        daysRemaining: 4,
        stockLevel: StockLevel.low,
      );

      await pumpAppWidget(
        tester,
        const StockOverviewScreen(),
        overrides: [
          medicationsStockProvider.overrideWith((ref) async => [mockStock]),
          stockStatisticsProvider.overrideWith(
            (ref) async => {
              'total': 1,
              'critical': 0,
              'low': 1,
              'medium': 0,
              'good': 0,
              'expired': 0,
              'expiring_soon': 0,
            },
          ),
        ],
      );

      await tester.pump(const Duration(milliseconds: 10));

      expect(find.text('Stock Overview'), findsOneWidget);
      expect(find.text('Stock Summary'), findsOneWidget);
      expect(find.text('Medications'), findsOneWidget);
    });
  });
}
