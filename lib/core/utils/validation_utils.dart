/// Numeric + bounds validation helpers for user-entered values.
///
/// Centralizes clamping/range checks so feature code does not repeat bounds.
class ValidationUtils {
  ValidationUtils._();

  static const int maxStockQuantity = 100000;
  static const double maxStockQuantityDouble = 100000;
  static const int minSnoozeMinutes = 1;
  static const int maxSnoozeMinutes = 180;
  static const int maxMedicationNameLength = 100;
  static const int maxNotesLength = 500;

  /// Clamp stock quantity to valid non-negative range.
  static double clampStockQuantity(double value) {
    if (value.isNaN || value.isInfinite || value < 0) return 0;
    if (value > maxStockQuantityDouble) return maxStockQuantityDouble;
    return value;
  }

  /// Clamp snooze minutes to [minSnoozeMinutes, maxSnoozeMinutes].
  static int clampSnoozeMinutes(int minutes) {
    if (minutes < minSnoozeMinutes) return minSnoozeMinutes;
    if (minutes > maxSnoozeMinutes) return maxSnoozeMinutes;
    return minutes;
  }

  /// Weekday index in [0,6] (Monday=0 ... Sunday=6) or null if out of bounds.
  static int? validWeekdayIndex(int index) {
    if (index < 0 || index > 6) return null;
    return index;
  }

  /// Hour in [0,23] or null if invalid.
  static int? validHour(int hour) {
    if (hour < 0 || hour > 23) return null;
    return hour;
  }

  /// Minute in [0,59] or null if invalid.
  static int? validMinute(int minute) {
    if (minute < 0 || minute > 59) return null;
    return minute;
  }

  /// Trim + enforce max length for free-text fields.
  static String clampString(String value, int maxLength) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  /// True if string is non-empty after trimming.
  static bool isNonEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
