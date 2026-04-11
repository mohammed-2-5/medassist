/// Shared time-of-day period classification.
class TimePeriodUtils {
  const TimePeriodUtils._();

  static const morning = 'Morning (6 AM - 12 PM)';
  static const afternoon = 'Afternoon (12 PM - 6 PM)';
  static const evening = 'Evening (6 PM - 10 PM)';
  static const night = 'Night (10 PM - 6 AM)';

  static const allPeriods = [morning, afternoon, evening, night];

  /// Classify an hour (0-23) into a time period label.
  static String periodForHour(int hour) {
    if (hour >= 6 && hour < 12) return morning;
    if (hour >= 12 && hour < 18) return afternoon;
    if (hour >= 18 && hour < 22) return evening;
    return night;
  }
}
