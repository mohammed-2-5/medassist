/// Typed error model for the application
class AppError {

  const AppError({
    required this.message,
    required this.type, this.userMessage,
    this.originalError,
    this.stackTrace,
  });
  final String message;
  final String? userMessage;
  final AppErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;

  /// User-friendly message for display
  String get displayMessage {
    return userMessage ?? _getDefaultMessage();
  }

  String _getDefaultMessage() {
    switch (type) {
      case AppErrorType.network:
        return 'Network connection issue. Please check your internet.';
      case AppErrorType.database:
        return 'Database error. Please try again.';
      case AppErrorType.notification:
        return 'Notification issue. Check app permissions.';
      case AppErrorType.validation:
        return 'Please check your input and try again.';
      case AppErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, userMessage: $userMessage)';
  }
}

/// Types of errors in the application
enum AppErrorType {
  network,
  database,
  notification,
  validation,
  unknown,
}
