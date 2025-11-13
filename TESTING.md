# Testing Documentation - Med Assist

## Overview

This document provides comprehensive information about the testing infrastructure for the Med Assist application. The project follows industry best practices with a multi-layered testing approach.

## Test Statistics

**Total Tests**: 267 tests
- **Unit Tests**: 163 tests ✅ 100% passing
- **Integration Tests**: 85 tests ✅ 100% passing
- **Widget Tests**: 16 tests ✅ 100% passing
- **E2E Tests**: 3 tests ✅ 100% passing

**Execution Time**: ~10 seconds total
**Coverage**: All critical features tested

## Test Structure

```
test/
├── unit/                           # Unit tests for individual components
│   ├── database/
│   │   ├── medication_crud_test.dart
│   │   ├── reminder_times_test.dart
│   │   ├── dose_history_test.dart
│   │   ├── search_test.dart
│   │   └── soft_delete_test.dart
│   └── helpers/
│       └── test_helpers.dart
│
├── integration/                    # Integration tests for feature workflows
│   ├── medication_flow_test.dart
│   ├── reminder_flow_test.dart
│   ├── dose_tracking_flow_test.dart
│   ├── adherence_analytics_test.dart
│   ├── stock_management_test.dart
│   └── helpers/
│       └── test_helpers.dart
│
├── widget/                         # Widget tests for UI components
│   ├── core_widgets_test.dart
│   └── helpers/
│       └── widget_test_helpers.dart
│
└── e2e/                           # End-to-end tests for complete user journeys
    └── medication_lifecycle_e2e_test.dart
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Suites

**Unit Tests Only**
```bash
flutter test test/unit
```

**Integration Tests Only**
```bash
flutter test test/integration
```

**Widget Tests Only**
```bash
flutter test test/widget
```

**E2E Tests Only**
```bash
flutter test test/e2e
```

### Run Specific Test File
```bash
flutter test test/unit/database/medication_crud_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

View coverage report:
```bash
# Generate HTML coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
# Open coverage/html/index.html in your browser
```

## Test Types Explained

### 1. Unit Tests (`test/unit/`)

**Purpose**: Test individual functions, methods, and classes in isolation

**What They Test**:
- Database CRUD operations
- Reminder time calculations
- Dose history tracking
- Search functionality
- Soft delete behavior
- Data validation

**Example**:
```dart
test('Insert medication successfully', () async {
  final medId = await db.insertMedication(
    createTestMedication(name: 'Aspirin'),
  );

  expect(medId, greaterThan(0));

  final med = await db.getMedicationById(medId);
  expect(med!.medicineName, equals('Aspirin'));
});
```

### 2. Integration Tests (`test/integration/`)

**Purpose**: Test how multiple components work together

**What They Test**:
- Complete medication management flows
- Reminder scheduling workflows
- Dose tracking with analytics
- Stock management with notifications
- Adherence calculations
- Data consistency across operations

**Example**:
```dart
test('Complete medication flow: add → configure → verify', () async {
  // Add medication
  final medId = await db.insertMedication(testMed);

  // Add reminder times
  await db.insertReminderTimes(medId, times);

  // Verify complete setup
  final med = await db.getMedicationById(medId);
  final reminders = await db.getReminderTimes(medId);

  expect(med, isNotNull);
  expect(reminders.length, equals(2));
});
```

### 3. Widget Tests (`test/widget/`)

**Purpose**: Test UI components and their interactions

**What They Test**:
- Widget rendering
- User interactions (taps, scrolls, text input)
- Layout responsiveness
- Edge cases (long text, empty states)
- Accessibility
- Visual states

**Example**:
```dart
testWidgets('EmptyStateWidget displays content', (tester) async {
  await tester.pumpWidget(
    createTestApp(
      EmptyStateWidget(
        icon: Icons.medical_services,
        title: 'No Medications',
        subtitle: 'Add your first medication',
      ),
    ),
  );

  expect(find.byIcon(Icons.medical_services), findsOneWidget);
  expect(find.text('No Medications'), findsOneWidget);
});
```

### 4. E2E Tests (`test/e2e/`)

**Purpose**: Test complete user journeys from start to finish

**What They Test**:
- Complete medication lifecycle
- Multi-medication management
- Stock management with expiry tracking
- Real-world user scenarios
- Data persistence across operations

**Example**:
```dart
test('User Journey: Add medication → Take doses → View analytics', () async {
  // Step 1: Add medication
  final medId = await db.insertMedication(...);

  // Step 2: Configure reminders
  await db.insertReminderTimes(medId, times);

  // Step 3: Take doses over time
  for (int day = 0; day < 7; day++) {
    await db.recordDoseTaken(...);
  }

  // Step 4: Verify analytics
  final adherence = await db.getAdherenceStats(...);
  expect(adherence['taken'], greaterThan(0));
});
```

## Test Helpers

### Unit & Integration Test Helpers

**Location**: `test/unit/helpers/test_helpers.dart`, `test/integration/helpers/test_helpers.dart`

**Utilities**:
```dart
// Create test database
AppDatabase createTestDatabase()

// Create test medication
MedicationsCompanion createTestMedication({...})

// Create test reminder times
List<ReminderTime> createTestReminderTimes({...})

// Clean up database
Future<void> cleanupDatabase(AppDatabase db)
```

### Widget Test Helpers

**Location**: `test/widget/helpers/widget_test_helpers.dart`

**Utilities**:
```dart
// Wrap widget for testing
Widget createTestApp(Widget child)

// Find widgets
Finder findByKey(String key)
Finder findByText(String text)
Finder findByIcon(IconData icon)

// Interactions
Future<void> tapAndSettle(WidgetTester tester, Finder finder)
Future<void> enterText(WidgetTester tester, Finder finder, String text)
Future<void> waitForWidget(WidgetTester tester, Finder finder)

// Assertions
void expectWidgetExists(Finder finder)
void expectWidgetNotExists(Finder finder)
```

## CI/CD Pipeline

### GitHub Actions Workflow

**Location**: `.github/workflows/flutter_ci.yml`

**Configuration**:
- **Flutter Version**: 3.24.3 (stable)
- **Triggers**: Push to main/master/develop, Pull Requests, Manual dispatch
- **Platform**: Ubuntu (tests), macOS (iOS builds)

**Pipeline Stages**:

1. **Test Job** (runs on every push/PR)
   - Code formatting verification
   - Static code analysis
   - Unit tests with coverage
   - Integration tests
   - Widget tests
   - E2E tests
   - Coverage upload to Codecov

2. **Build Android Job** (runs after tests pass)
   - Build release APK
   - Upload APK artifact

3. **Build iOS Job** (runs after tests pass)
   - Build iOS app (no codesign)

### Viewing CI Results

1. Go to your repository on GitHub
2. Click on "Actions" tab
3. View test results and build status
4. Download APK artifacts from successful builds

### Local CI Simulation

Run the same checks locally before pushing:

```bash
# Format check
dart format --output=none --set-exit-if-changed .

# Analysis
flutter analyze

# All tests
flutter test

# Build APK
flutter build apk --release
```

## Writing New Tests

### Adding Unit Tests

1. Create test file in `test/unit/` directory
2. Import test helpers: `import '../helpers/test_helpers.dart';`
3. Set up database in `setUp()`, clean up in `tearDown()`
4. Write focused tests for individual functions

**Template**:
```dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await cleanupDatabase(db);
  });

  group('Feature Name Tests', () {
    test('Should do something specific', () async {
      // Arrange
      final input = 'test data';

      // Act
      final result = await db.someMethod(input);

      // Assert
      expect(result, equals(expectedValue));
    });
  });
}
```

### Adding Integration Tests

1. Create test file in `test/integration/` directory
2. Test complete workflows spanning multiple operations
3. Verify data consistency across operations

### Adding Widget Tests

1. Create test file in `test/widget/` directory
2. Import widget test helpers
3. Use `testWidgets()` for each test case
4. Use `pumpWidget()` to render, `pumpAndSettle()` to wait for animations

**Template**:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'helpers/widget_test_helpers.dart';

void main() {
  testWidgets('Widget should display correctly', (tester) async {
    // Arrange & Act
    await tester.pumpWidget(
      createTestApp(YourWidget()),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Expected Text'), findsOneWidget);
  });
}
```

### Adding E2E Tests

1. Create test file in `test/e2e/` directory
2. Write complete user journey scenarios
3. Add detailed logging with print statements
4. Verify end-to-end data flow

## Best Practices

### General
- ✅ Each test should be independent and isolated
- ✅ Use descriptive test names that explain what is being tested
- ✅ Follow the Arrange-Act-Assert pattern
- ✅ Clean up resources in `tearDown()`
- ✅ Use test helpers to reduce code duplication
- ✅ Test both happy paths and edge cases

### Unit Tests
- ✅ Test one thing per test
- ✅ Use mock data from test helpers
- ✅ Test boundary conditions
- ✅ Verify error handling

### Integration Tests
- ✅ Test realistic workflows
- ✅ Verify data consistency
- ✅ Test cross-feature interactions
- ✅ Include timing considerations

### Widget Tests
- ✅ Test user interactions
- ✅ Verify visual states
- ✅ Test accessibility
- ✅ Handle animations with `pumpAndSettle()`
- ✅ Test different screen sizes

### E2E Tests
- ✅ Simulate real user journeys
- ✅ Add detailed logging for debugging
- ✅ Test complete workflows end-to-end
- ✅ Verify data persistence

## Troubleshooting

### Tests Failing Locally

**Issue**: Tests fail on your machine but pass in CI

**Solutions**:
- Ensure Flutter SDK version matches CI (3.24.3)
- Run `flutter clean && flutter pub get`
- Check for platform-specific issues
- Verify database isolation between tests

### Widget Tests Timing Out

**Issue**: Widget tests hang or timeout

**Solutions**:
- Increase timeout: `testWidgets(..., timeout: Timeout(Duration(minutes: 2)))`
- Use `pumpAndSettle()` to wait for animations
- Check for infinite animations
- Verify widget tree is properly disposed

### Database Tests Failing

**Issue**: Database tests fail with state conflicts

**Solutions**:
- Ensure each test uses `NativeDatabase.memory()`
- Clean up in `tearDown()`: hard delete all medications
- Don't share database instances between tests
- Reset IDs by using fresh database

### Coverage Reports Not Generating

**Issue**: Coverage data not collected

**Solutions**:
```bash
# Clean and regenerate
flutter clean
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Code Coverage Goals

**Current Coverage**: Tests cover all critical functionality

**Target Coverage**:
- Core database operations: 100%
- Business logic: ≥90%
- UI widgets: ≥80%
- Overall: ≥85%

## Additional Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/cookbook/testing/integration/introduction)

## Need Help?

If you encounter issues with testing:
1. Check this documentation
2. Review existing test examples
3. Check CI logs for detailed error messages
4. Ensure dependencies are up to date

---

**Last Updated**: November 2024
**Maintained By**: Development Team
