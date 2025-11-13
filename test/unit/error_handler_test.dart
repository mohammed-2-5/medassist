import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/core/errors/app_error.dart';
import 'package:med_assist/core/errors/error_handler_service.dart';

void main() {
  late ErrorHandlerService errorHandler;

  setUp(() {
    errorHandler = ErrorHandlerService();
  });

  group('ErrorHandlerService Tests', () {
    test('Singleton instance returns same object', () {
      final instance1 = ErrorHandlerService();
      final instance2 = ErrorHandlerService();
      expect(instance1, same(instance2));
    });

    test('Initialize sets up error handlers', () async {
      // Initialize error handler
      await errorHandler.initialize();

      // Verify FlutterError.onError is set
      expect(FlutterError.onError, isNotNull);
    });

    test('Capture logs error in debug mode', () {
      // In debug mode, capture should not throw
      expect(
        () => errorHandler.capture(
          Exception('Test error'),
          stackTrace: StackTrace.current,
          reason: 'Test',
        ),
        returnsNormally,
      );
    });

    test('Capture with context data', () {
      final context = {
        'userId': '123',
        'screen': 'home',
        'action': 'load_medications',
      };

      expect(
        () => errorHandler.capture(
          Exception('Test error with context'),
          stackTrace: StackTrace.current,
          reason: 'Test with context',
          context: context,
        ),
        returnsNormally,
      );
    });
  });

  group('AppError Tests', () {
    test('Create network error', () {
      final error = AppError(
        message: 'Connection timeout',
        type: AppErrorType.network,
        originalError: Exception('Timeout'),
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

    test('Create validation error', () {
      const error = AppError(
        message: 'Invalid input',
        type: AppErrorType.validation,
        userMessage: 'Please enter a valid medication name',
      );

      expect(error.type, AppErrorType.validation);
      expect(error.displayMessage, 'Please enter a valid medication name');
    });

    test('Create notification error', () {
      const error = AppError(
        message: 'Permission denied',
        type: AppErrorType.notification,
      );

      expect(error.type, AppErrorType.notification);
      expect(
        error.displayMessage,
        'Notification issue. Check app permissions.',
      );
    });

    test('Create unknown error with custom message', () {
      const error = AppError(
        message: 'Something went wrong',
        type: AppErrorType.unknown,
        userMessage: 'An unexpected error occurred. Please restart the app.',
      );

      expect(error.type, AppErrorType.unknown);
      expect(
        error.displayMessage,
        'An unexpected error occurred. Please restart the app.',
      );
    });

    test('Unknown error falls back to default message', () {
      const error = AppError(
        message: 'Internal error',
        type: AppErrorType.unknown,
      );

      expect(error.displayMessage, 'Something went wrong. Please try again.');
    });

    test('Error toString contains type and message', () {
      const error = AppError(
        message: 'Test error',
        type: AppErrorType.database,
        userMessage: 'User friendly message',
      );

      final str = error.toString();
      expect(str, contains('database'));
      expect(str, contains('Test error'));
      expect(str, contains('User friendly message'));
    });

    test('Error with stack trace', () {
      final stackTrace = StackTrace.current;
      final error = AppError(
        message: 'Error with stack',
        type: AppErrorType.unknown,
        stackTrace: stackTrace,
      );

      expect(error.stackTrace, isNotNull);
      expect(error.stackTrace, equals(stackTrace));
    });

    test('All error types have default messages', () {
      for (final type in AppErrorType.values) {
        final error = AppError(
          message: 'Test',
          type: type,
        );

        // Should not throw and should return a non-empty message
        expect(error.displayMessage, isNotEmpty);
      }
    });
  });

  group('Error Type Coverage', () {
    test('Network error type', () {
      expect(AppErrorType.network, isNotNull);
    });

    test('Database error type', () {
      expect(AppErrorType.database, isNotNull);
    });

    test('Notification error type', () {
      expect(AppErrorType.notification, isNotNull);
    });

    test('Validation error type', () {
      expect(AppErrorType.validation, isNotNull);
    });

    test('Unknown error type', () {
      expect(AppErrorType.unknown, isNotNull);
    });
  });
}
