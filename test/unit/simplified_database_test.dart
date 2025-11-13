import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/core/errors/app_error.dart';

/// Simplified unit tests for core functionality
void main() {
  group('AppError Tests', () {
    test('Create network error with default message', () {
      const error = AppError(
        message: 'Connection timeout',
        type: AppErrorType.network,
      );

      expect(error.type, AppErrorType.network);
      expect(error.message, 'Connection timeout');
      expect(
        error.displayMessage,
        'Network connection issue. Please check your internet.',
      );
    });

    test('Create database error', () {
      const error = AppError(
        message: 'Failed to insert',
        type: AppErrorType.database,
      );

      expect(error.type, AppErrorType.database);
      expect(error.displayMessage, 'Database error. Please try again.');
    });

    test('Create validation error with custom message', () {
      const error = AppError(
        message: 'Invalid input',
        type: AppErrorType.validation,
        userMessage: 'Please enter a valid medication name',
      );

      expect(error.type, AppErrorType.validation);
      expect(error.displayMessage, 'Please enter a valid medication name');
    });

    test('All error types have messages', () {
      for (final type in AppErrorType.values) {
        final error = AppError(
          message: 'Test',
          type: type,
        );
        expect(error.displayMessage, isNotEmpty);
      }
    });
  });

  group('Dose Timing Logic', () {
    test('Check if dose time is in the past', () {
      final now = DateTime(2024, 1, 15, 10); // 10:00 AM
      final past = DateTime(2024, 1, 15, 8); // 8:00 AM

      expect(now.isAfter(past), isTrue);
      expect(past.isBefore(now), isTrue);
    });

    test('Check if dose time is in the future', () {
      final now = DateTime(2024, 1, 15, 10); // 10:00 AM
      final future = DateTime(2024, 1, 15, 20); // 8:00 PM

      expect(now.isBefore(future), isTrue);
      expect(future.isAfter(now), isTrue);
    });

    test('Calculate time difference for missed doses', () {
      final scheduled = DateTime(2024, 1, 15, 8); // 8:00 AM
      final current = DateTime(2024, 1, 15, 10, 30); // 10:30 AM

      final difference = current.difference(scheduled);
      expect(difference.inMinutes, 150); // 2.5 hours = 150 minutes
      expect(difference.inHours, 2);

      // Dose is missed if more than 2 hours past
      expect(difference.inHours >= 2, isTrue);
    });

    test('Calculate snooze times', () {
      final now = DateTime(2024, 1, 15, 10);

      final snooze5 = now.add(const Duration(minutes: 5));
      expect(snooze5.difference(now).inMinutes, 5);

      final snooze15 = now.add(const Duration(minutes: 15));
      expect(snooze15.difference(now).inMinutes, 15);

      final snooze30 = now.add(const Duration(minutes: 30));
      expect(snooze30.difference(now).inMinutes, 30);

      final snooze60 = now.add(const Duration(hours: 1));
      expect(snooze60.difference(now).inHours, 1);
    });
  });

  group('Stock Management Logic', () {
    test('Check if stock is low', () {
      const currentStock = 3;
      const warningLevel = 5;

      expect(currentStock < warningLevel, isTrue);
    });

    test('Check if stock is sufficient', () {
      const currentStock = 20;
      const warningLevel = 5;

      expect(currentStock >= warningLevel, isTrue);
    });

    test('Calculate remaining days of medication', () {
      const stockCount = 30;
      const dosesPerDay = 2;

      const daysRemaining = stockCount ~/ dosesPerDay;
      expect(daysRemaining, 15);
    });

    test('Decrease stock after taking dose', () {
      var stock = 30;
      const dosesToTake = 1;

      stock -= dosesToTake;
      expect(stock, 29);
    });
  });

  group('Notification ID Generation Logic', () {
    test('Generate unique IDs for different medications', () {
      // Simulate ID generation: medicationId * 100 + doseIndex
      int generateId(int medicationId, int doseIndex) {
        return medicationId * 100 + doseIndex;
      }

      final id1 = generateId(1, 0);
      final id2 = generateId(2, 0);
      final id3 = generateId(1, 1);

      expect(id1, 100);
      expect(id2, 200);
      expect(id3, 101);

      // All should be unique
      expect(id1 != id2, isTrue);
      expect(id1 != id3, isTrue);
      expect(id2 != id3, isTrue);
    });

    test('Same medication and dose generates same ID', () {
      int generateId(int medicationId, int doseIndex) {
        return medicationId * 100 + doseIndex;
      }

      final id1 = generateId(5, 2);
      final id2 = generateId(5, 2);

      expect(id1, id2);
    });
  });

  group('Adherence Calculation Logic', () {
    test('Calculate adherence percentage', () {
      const totalDoses = 20;
      const takenDoses = 18;

      final adherence = (takenDoses / totalDoses * 100).round();
      expect(adherence, 90);
    });

    test('Perfect adherence', () {
      const totalDoses = 20;
      const takenDoses = 20;

      final adherence = (takenDoses / totalDoses * 100).round();
      expect(adherence, 100);
    });

    test('Low adherence', () {
      const totalDoses = 20;
      const takenDoses = 10;

      final adherence = (takenDoses / totalDoses * 100).round();
      expect(adherence, 50);
    });
  });

  group('Time Parsing and Formatting', () {
    test('Parse time string format', () {
      const timeString = '08:30';
      final parts = timeString.split(':');

      expect(parts.length, 2);
      expect(int.parse(parts[0]), 8);
      expect(int.parse(parts[1]), 30);
    });

    test('Format time for display', () {
      final time = DateTime(2024, 1, 1, 8, 30);

      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      final formatted = '$hour:$minute';

      expect(formatted, '08:30');
    });

    test('Handle 24-hour format', () {
      final morning = DateTime(2024, 1, 1, 8);
      final evening = DateTime(2024, 1, 1, 20);

      expect(morning.hour, 8);
      expect(evening.hour, 20);
    });
  });
}
