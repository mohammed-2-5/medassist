/// Utility for evaluating medication repetition patterns.
///
/// Shared logic used by dose generation, stock calculations,
/// and anywhere pattern-based scheduling decisions are needed.
class RepetitionPatternUtils {
  const RepetitionPatternUtils._();

  /// Whether [date] is a scheduled dose day given the medication's
  /// [pattern], [specificDaysOfWeek] (comma-separated weekday numbers 1-7),
  /// and [startDate]. Interval params used for new patterns:
  /// everyNDays → [intervalDays]; weekly → [intervalWeeks] + weekdays;
  /// monthly → [intervalMonths] + [dayOfMonth].
  static bool isDoseDay({
    required String pattern,
    required String specificDaysOfWeek,
    required DateTime startDate,
    required DateTime date,
    int? intervalDays,
    int? intervalWeeks,
    int? intervalMonths,
    int? dayOfMonth,
  }) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final daysSinceStart = dateOnly.difference(startOnly).inDays;
    if (daysSinceStart < 0) return false;

    switch (pattern) {
      case 'daily':
        return true;
      case 'everyOtherDay':
        return daysSinceStart % 2 == 0;
      case 'everyNDays':
        final n = (intervalDays ?? 1).clamp(1, 365);
        return daysSinceStart % n == 0;
      case 'asNeeded':
        return false;
      case 'weekly':
        final weeksSinceStart = daysSinceStart ~/ 7;
        final n = (intervalWeeks ?? 1).clamp(1, 52);
        if (weeksSinceStart % n != 0) return false;
        return _matchesWeekday(date.weekday, specificDaysOfWeek);
      case 'monthly':
        final n = (intervalMonths ?? 1).clamp(1, 12);
        final monthsSinceStart =
            (date.year - startOnly.year) * 12 + (date.month - startOnly.month);
        if (monthsSinceStart < 0) return false;
        if (monthsSinceStart % n != 0) return false;
        final targetDay = (dayOfMonth ?? startOnly.day).clamp(1, 31);
        final lastDay = DateTime(date.year, date.month + 1, 0).day;
        final effectiveDay = targetDay > lastDay ? lastDay : targetDay;
        return date.day == effectiveDay;
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
    int? intervalDays,
    int? intervalWeeks,
    int? intervalMonths,
  }) {
    switch (pattern) {
      case 'daily':
        return 7;
      case 'everyOtherDay':
        return 3.5;
      case 'everyNDays':
        final n = (intervalDays ?? 1).clamp(1, 365);
        return 7 / n;
      case 'weekdays':
        return 5;
      case 'weekends':
        return 2;
      case 'twiceAWeek':
        return 2;
      case 'thriceAWeek':
        return 3;
      case 'weekly':
        final days = specificDaysOfWeek
            .split(',')
            .where((d) => d.trim().isNotEmpty)
            .length;
        final n = (intervalWeeks ?? 1).clamp(1, 52);
        return days / n;
      case 'monthly':
        final n = (intervalMonths ?? 1).clamp(1, 12);
        // ~1 dose per month / N months → per week
        return (12 / n) / 52;
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
