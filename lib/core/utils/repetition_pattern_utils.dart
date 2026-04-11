/// Utility for evaluating medication repetition patterns.
///
/// Shared logic used by dose generation, stock calculations,
/// and anywhere pattern-based scheduling decisions are needed.
class RepetitionPatternUtils {
  const RepetitionPatternUtils._();

  /// Whether [date] is a scheduled dose day given the medication's
  /// [pattern], [specificDaysOfWeek] (comma-separated weekday numbers 1-7),
  /// and [startDate].
  static bool isDoseDay({
    required String pattern,
    required String specificDaysOfWeek,
    required DateTime startDate,
    required DateTime date,
  }) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final daysSinceStart = dateOnly.difference(startOnly).inDays;

    switch (pattern) {
      case 'daily':
        return true;
      case 'everyOtherDay':
        return daysSinceStart % 2 == 0;
      case 'asNeeded':
        return false;
      case 'twiceAWeek':
      case 'thriceAWeek':
      case 'weekdays':
      case 'weekends':
      case 'specificDays':
        return _matchesWeekday(date.weekday, specificDaysOfWeek);
      default:
        return true;
    }
  }

  /// Average number of dose-days per week for a given pattern.
  ///
  /// Used to convert per-dose usage into average daily usage for
  /// stock duration estimates.
  static double doseDaysPerWeek({
    required String pattern,
    required String specificDaysOfWeek,
  }) {
    switch (pattern) {
      case 'daily':
        return 7;
      case 'everyOtherDay':
        return 3.5;
      case 'weekdays':
        return 5;
      case 'weekends':
        return 2;
      case 'twiceAWeek':
        return 2;
      case 'thriceAWeek':
        return 3;
      case 'asNeeded':
        return 0;
      case 'specificDays':
        final days = specificDaysOfWeek
            .split(',')
            .where((d) => d.trim().isNotEmpty)
            .toList();
        return days.length.toDouble();
      default:
        return 7;
    }
  }

  static bool _matchesWeekday(int weekday, String specificDaysOfWeek) {
    final days = specificDaysOfWeek
        .split(',')
        .where((d) => d.trim().isNotEmpty)
        .map((d) => int.tryParse(d.trim()))
        .whereType<int>()
        .toList();
    return days.contains(weekday);
  }
}
