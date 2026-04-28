import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/features/medications/providers/medications_filter_provider.dart';
import 'package:med_assist/features/medications/screens/medications_list_screen.dart';

import '../helpers/widget_test_helpers.dart';

void main() {
  group('MedicationsListScreen', () {
    testWidgets('shows empty message when list is empty', (tester) async {
      await pumpAppWidget(
        tester,
        const MedicationsListScreen(),
        overrides: [
          filteredMedicationsProvider.overrideWith((ref) async => []),
        ],
      );

      expect(find.text('No medications yet'), findsOneWidget);
    });

    testWidgets('renders medication cards when data available', (tester) async {
      final mockMedication = TestDataFactory.medication(name: 'Metformin');

      await pumpAppWidget(
        tester,
        const MedicationsListScreen(),
        overrides: [
          filteredMedicationsProvider.overrideWith(
            (ref) async => [mockMedication],
          ),
        ],
      );

      expect(find.text('Metformin'), findsOneWidget);
      expect(find.textContaining('stock'), findsWidgets);
    });
  });
}
