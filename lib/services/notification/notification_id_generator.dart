/// Generates unique notification IDs for different notification types.
///
/// ID scheme per medication:
/// - `medicationId * 100 + 0..5` — reminder time slots
/// - `medicationId * 100 + 7` — expiry notification
/// - `medicationId * 100 + 8` — low stock notification
/// - `medicationId * 100 + 9` — snooze notification
/// - `medicationId * 100 + 10 + reminderIndex * 10 + escalation` — recurring
/// - `medicationId * 1000 + scheduledDay * 10 + reminderIndex` — pattern-aware
class NotificationIdGenerator {
  NotificationIdGenerator._();

  static const _maxInt32 = 2147483647;

  /// Reminder slot: medicationId * 100 + reminderIndex.
  static int reminder(int medicationId, int reminderIndex) {
    return ((medicationId * 100 + reminderIndex) % _maxInt32).abs();
  }

  /// Low stock: medicationId * 100 + 8.
  static int lowStock(int medicationId) {
    return medicationId * 100 + 8;
  }

  /// Snooze: medicationId * 100 + 9.
  static int snooze(int medicationId) {
    return medicationId * 100 + 9;
  }

  /// Expiry: medicationId * 100 + 7.
  static int expiry(int medicationId) {
    return medicationId * 100 + 7;
  }

  /// Recurring: medicationId * 100 + 10 + reminderIndex * 10 + escalationLevel.
  static int recurring(
    int medicationId,
    int reminderIndex,
    int escalationLevel,
  ) {
    return ((medicationId * 100 + 10 + reminderIndex * 10 + escalationLevel) %
            _maxInt32)
        .abs();
  }

  /// Pattern-aware: medicationId * 1000 + scheduledDayIndex * 10 + reminderIndex.
  static int patternAware(
    int medicationId,
    int scheduledDayIndex,
    int reminderIndex,
  ) {
    return ((medicationId * 1000 + scheduledDayIndex * 10 + reminderIndex) %
            _maxInt32)
        .abs();
  }
}
