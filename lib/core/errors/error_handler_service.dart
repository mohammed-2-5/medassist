import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:med_assist/core/errors/app_error.dart';

/// Global error handler service for the application
/// Singleton pattern - use ErrorHandlerService() to access
class ErrorHandlerService {
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();

//  late final FirebaseCrashlytics _crashlytics;
  bool _initialized = false;

  /// Initialize error handler with Flutter error callbacks
  Future<void> initialize() async {
    if (_initialized) return;

    //_crashlytics = FirebaseCrashlytics.instance;

    // Set up Flutter error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      capture(
        details.exception,
        stackTrace: details.stack,
        reason: 'Flutter Error',
      );
    };

    // Set up platform error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      capture(error, stackTrace: stack, reason: 'Platform Error');
      return true;
    };

    _initialized = true;
  }

  /// Capture and report an error
  ///
  /// - In debug mode: prints to console
  /// - In release mode: sends to Crashlytics
  void capture(
    dynamic error, {
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? context,
  }) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
      if (reason != null) {
        debugPrint('Reason: $reason');
      }
    }

    // if (kReleaseMode) {
    //   _crashlytics.recordError(
    //     error,
    //     stackTrace,
    //     reason: reason,
    //     information: context?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
    //   );
    // }
  }

  /// Show user-friendly error notification
  ///
  /// Displays a SnackBar with the error message
  void notifyUser(
    BuildContext context,
    String message, {
    bool isError = true,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;

    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Notify user with AppError
  void notifyUserWithError(BuildContext context, AppError error) {
    notifyUser(context, error.displayMessage);
    capture(
      error.originalError ?? error.message,
      stackTrace: error.stackTrace,
      reason: error.type.toString(),
    );
  }

  /// Run a function with error handling
  ///
  /// Catches errors and notifies user automatically
  Future<T?> runWithErrorHandling<T>(
    Future<T> Function() function, {
    required BuildContext context,
    String? errorMessage,
    bool showError = true,
  }) async {
    try {
      return await function();
    } catch (e, stack) {
      capture(e, stackTrace: stack, reason: 'Handled error');
      if (showError && context.mounted) {
        notifyUser(
          context,
          errorMessage ?? 'An error occurred. Please try again.',
        );
      }
      return null;
    }
  }
}
