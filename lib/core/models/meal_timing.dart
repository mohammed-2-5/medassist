/// Enum for meal timing options
enum MealTiming {
  anytime('anytime', 'Anytime', 0),
  beforeMeal('before_meal', 'Before meal', -30), // 30 minutes before
  withMeal('with_meal', 'With meal', 0),
  afterMeal('after_meal', 'After meal', 30); // 30 minutes after

  const MealTiming(this.value, this.label, this.defaultOffsetMinutes);

  final String value;
  final String label;
  final int defaultOffsetMinutes; // Offset from meal time

  static MealTiming fromString(String value) {
    return MealTiming.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MealTiming.anytime,
    );
  }
}
