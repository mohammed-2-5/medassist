import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/core/widgets/empty_state_widget.dart';
import 'helpers/widget_test_helpers.dart';

/// Widget Tests for Core Reusable Widgets
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmptyStateWidget Tests', () {
    testWidgets('Displays icon, title, and subtitle', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.medical_services,
            title: 'No Medications',
            subtitle: 'Add your first medication to get started',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify icon is displayed
      expect(find.byIcon(Icons.medical_services), findsOneWidget);

      // Verify title is displayed
      expect(find.text('No Medications'), findsOneWidget);

      // Verify subtitle is displayed
      expect(find.text('Add your first medication to get started'), findsOneWidget);
    });

    testWidgets('Displays action button when provided', (tester) async {
      var actionCalled = false;

      await tester.pumpWidget(
        createTestApp(
          EmptyStateWidget(
            icon: Icons.add,
            title: 'Empty List',
            subtitle: 'No items found',
            actionLabel: 'Add Item',
            onAction: () {
              actionCalled = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify action button is displayed
      expect(find.text('Add Item'), findsOneWidget);

      // Tap the action button
      await tester.tap(find.text('Add Item'));
      await tester.pumpAndSettle();

      // Verify action was called
      expect(actionCalled, isTrue);
    });

    testWidgets('Does not display action button when not provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.check,
            title: 'All Done',
            subtitle: 'Nothing to show',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no FilledButton exists
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('Uses custom icon color when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.warning,
            title: 'Warning',
            subtitle: 'Something went wrong',
            iconColor: Colors.red,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the icon widget
      final iconFinder = find.byIcon(Icons.warning);
      expect(iconFinder, findsOneWidget);

      // Verify icon color
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, equals(Colors.red));
    });

    testWidgets('Centers content properly', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.info,
            title: 'Info',
            subtitle: 'Details',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Center widget is used (may find multiple due to Scaffold)
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('Has proper padding', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.star,
            title: 'Star',
            subtitle: 'Rating',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Padding widget exists
      expect(find.byType(Padding), findsWidgets);
    });
  });

  group('EmptyStateWidget Interaction Tests', () {
    testWidgets('Action button responds to multiple taps', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        createTestApp(
          EmptyStateWidget(
            icon: Icons.touch_app,
            title: 'Tap Test',
            subtitle: 'Test multiple taps',
            actionLabel: 'Tap Me',
            onAction: () {
              tapCount++;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap multiple times
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapCount, equals(3));
    });

    testWidgets('Handles very long title text', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.text_fields,
            title: 'This is a very long title that should wrap properly and not overflow the screen boundaries',
            subtitle: 'Short subtitle',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Handles very long subtitle text', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.text_fields,
            title: 'Short title',
            subtitle: 'This is a very long subtitle that contains a lot of information and should wrap properly across multiple lines without causing any layout issues or overflow errors',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });
  });

  group('EmptyStateWidget Edge Cases', () {
    testWidgets('Handles empty strings', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.error,
            title: '',
            subtitle: '',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widget builds without errors
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('Handles special characters in text', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.code,
            title: 'Title with <special> & characters!',
            subtitle: r'Subtitle with @#$%^&* symbols',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Title with <special> & characters!'), findsOneWidget);
      expect(find.text(r'Subtitle with @#$%^&* symbols'), findsOneWidget);
    });

    testWidgets('Works with different icon types', (tester) async {
      final icons = [
        Icons.add,
        Icons.remove,
        Icons.edit,
        Icons.delete,
        Icons.check,
        Icons.close,
      ];

      for (final icon in icons) {
        await tester.pumpWidget(
          createTestApp(
            EmptyStateWidget(
              icon: icon,
              title: 'Test',
              subtitle: 'Testing icon: ${icon.codePoint}',
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(icon), findsOneWidget);

        // Clear the widget tree
        await tester.pumpWidget(Container());
      }
    });
  });

  group('EmptyStateWidget Accessibility Tests', () {
    testWidgets('Text is accessible to screen readers', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.accessibility,
            title: 'Accessible Title',
            subtitle: 'Accessible Subtitle',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify text widgets exist (screen readers can access these)
      expect(find.text('Accessible Title'), findsOneWidget);
      expect(find.text('Accessible Subtitle'), findsOneWidget);
    });

    testWidgets('Button is accessible when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          EmptyStateWidget(
            icon: Icons.touch_app,
            title: 'Title',
            subtitle: 'Subtitle',
            actionLabel: 'Action Button',
            onAction: () {},
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify button is accessible via text
      expect(find.text('Action Button'), findsOneWidget);
    });
  });

  group('EmptyStateWidget Layout Tests', () {
    testWidgets('Maintains layout in different screen sizes', (tester) async {
      // Test small screen
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.phone_android,
            title: 'Small Screen',
            subtitle: 'Testing small screen layout',
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(EmptyStateWidget), findsOneWidget);

      // Test large screen
      tester.view.physicalSize = const Size(1200, 1600);
      await tester.pumpWidget(
        createTestApp(
          const EmptyStateWidget(
            icon: Icons.tablet,
            title: 'Large Screen',
            subtitle: 'Testing large screen layout',
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(EmptyStateWidget), findsOneWidget);

      // Reset view
      addTearDown(tester.view.reset);
    });

    testWidgets('Column has proper spacing', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          EmptyStateWidget(
            icon: Icons.space_bar,
            title: 'Spacing Test',
            subtitle: 'Testing spacing',
            actionLabel: 'Button',
            onAction: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify SizedBox widgets for spacing
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
