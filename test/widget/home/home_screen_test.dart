import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/features/home/models/dose_event.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/features/home/screens/home_screen.dart';
import 'package:med_assist/features/home/widgets/enhanced_empty_state.dart';
import 'package:med_assist/features/home/widgets/timeline_section.dart';
import 'package:med_assist/features/medications/providers/drug_interaction_providers.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';

import '../helpers/widget_test_helpers.dart';

class _StaticNotificationNotifier extends NotificationPermissionNotifier {
  _StaticNotificationNotifier(this.value);
  final bool value;

  @override
  bool build() => value;
}

void main() {
  group('HomeScreen', () {
    testWidgets('shows empty state when no medications', (tester) async {
      await pumpAppWidget(
        tester,
        const HomeScreen(),
        overrides: [
          hasMedicationsProvider.overrideWith((ref) async => false),
        ],
      );

      expect(find.byType(EnhancedEmptyState), findsOneWidget);
    });

    testWidgets('renders timeline data when medications exist', (tester) async {
      await pumpAppWidget(
        tester,
        const HomeScreen(),
        overrides: [
          hasMedicationsProvider.overrideWith((ref) async => true),
          notificationPermissionProvider.overrideWith(
            () => _StaticNotificationNotifier(false),
          ),
          adherenceSummaryProvider.overrideWith(
            (ref) async => const AdherenceSummary(
              takenToday: 2,
              totalToday: 3,
              currentStreak: 5,
            ),
          ),
          groupedDosesProvider.overrideWithValue({
            'Morning': [
              TestDataFactory.doseEvent(
                
              ),
            ],
            'Afternoon': <DoseEvent>[],
            'Evening': <DoseEvent>[],
            'Night': <DoseEvent>[],
          }),
          allInteractionsProvider.overrideWith((ref) async => <InteractionWarning>[]),
        ],
      );

      expect(find.byType(TimelineSection), findsNWidgets(4));
      expect(find.textContaining('Health Insights'), findsOneWidget);
      expect(find.textContaining('Quick Actions'), findsOneWidget);
    });
  });
}
