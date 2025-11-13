/// Health Insight Model
class HealthInsight {

  const HealthInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.value,
    required this.sentiment,
    required this.icon,
  });
  final HealthInsightType type;
  final String title;
  final String description;
  final double value;
  final InsightSentiment sentiment;
  final String icon;
}

/// Types of health insights
enum HealthInsightType {
  adherenceSummary,
  trend,
  bestPerforming,
  streak,
  bestTime,
  motivation,
}

/// Sentiment of the insight
enum InsightSentiment {
  positive,
  neutral,
  warning,
}
