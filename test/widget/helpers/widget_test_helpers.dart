import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/core/database/app_database.dart';

/// Widget Test Helpers
/// Utilities for setting up and managing widget tests

/// Create a test database for widget tests
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Wrap a widget with MaterialApp for testing
Widget createTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

/// Wrap a widget with just MaterialApp (no Scaffold)
Widget createTestAppSimple(Widget child) {
  return MaterialApp(
    home: child,
  );
}

/// Find a widget by key
Finder findByKey(String key) => find.byKey(Key(key));

/// Find a widget by text
Finder findByText(String text) => find.text(text);

/// Find a widget by icon
Finder findByIcon(IconData icon) => find.byIcon(icon);

/// Find a widget by type
Finder findByType<T>() => find.byType(T);

/// Tap a widget and settle
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Enter text into a field and settle
Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Scroll until visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
  Finder scrollable, {
  double delta = 100.0,
}) async {
  await tester.scrollUntilVisible(finder, delta, scrollable: scrollable);
  await tester.pumpAndSettle();
}

/// Wait for a widget to appear
Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = tester.binding.clock.now().add(timeout);

  do {
    if (tester.any(finder)) {
      return;
    }

    await tester.pump(const Duration(milliseconds: 100));
  } while (tester.binding.clock.now().isBefore(end));

  throw Exception('Widget not found: $finder');
}

/// Verify widget exists
void expectWidgetExists(Finder finder) {
  expect(finder, findsOneWidget);
}

/// Verify widget doesn't exist
void expectWidgetNotExists(Finder finder) {
  expect(finder, findsNothing);
}

/// Verify multiple widgets exist
void expectWidgetsExist(Finder finder, int count) {
  expect(finder, findsNWidgets(count));
}

/// Verify text contains
void expectTextContains(Finder finder, String substring) {
  final widget = finder.evaluate().first.widget as Text;
  expect(widget.data, contains(substring));
}

/// Get text from a Text widget
String getTextFromWidget(Finder finder) {
  final widget = finder.evaluate().first.widget as Text;
  return widget.data ?? '';
}

/// Create a mock medication for testing
Map<String, dynamic> createMockMedication({
  String name = 'Test Medication',
  String strength = '500',
  String unit = 'mg',
  int timesPerDay = 2,
  int stockQuantity = 30,
}) {
  return {
    'name': name,
    'strength': strength,
    'unit': unit,
    'timesPerDay': timesPerDay,
    'stockQuantity': stockQuantity,
  };
}

/// Create a mock dose for testing
Map<String, dynamic> createMockDose({
  required String medicationName,
  required DateTime scheduledTime,
  String status = 'pending',
}) {
  return {
    'medicationName': medicationName,
    'scheduledTime': scheduledTime,
    'status': status,
  };
}

/// Pump frames for animation
Future<void> pumpFrames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16)); // ~60fps
  }
}

/// Drag widget
Future<void> dragWidget(
  WidgetTester tester,
  Finder finder,
  Offset offset,
) async {
  await tester.drag(finder, offset);
  await tester.pumpAndSettle();
}

/// Long press widget
Future<void> longPressWidget(WidgetTester tester, Finder finder) async {
  await tester.longPress(finder);
  await tester.pumpAndSettle();
}

/// Verify widget is visible
void expectWidgetVisible(WidgetTester tester, Finder finder) {
  expect(tester.widget(finder).hashCode, isNonZero);
}

/// Verify widget has correct color
void expectWidgetColor(Finder finder, Color expectedColor) {
  final container = finder.evaluate().first.widget as Container;
  final decoration = container.decoration as BoxDecoration?;
  expect(decoration?.color, equals(expectedColor));
}

/// Clean up database after test
Future<void> cleanupTestDatabase(AppDatabase db) async {
  await db.close();
}
