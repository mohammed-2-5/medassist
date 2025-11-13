import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/insights/models/health_insight.dart';

/// Widget to display a health insight card
class InsightCard extends StatelessWidget {

  const InsightCard({
    required this.insight, super.key,
    this.index = 0,
  });
  final HealthInsight insight;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sentimentColor = _getSentimentColor(insight.sentiment);
    final sentimentGradient = _getSentimentGradient(insight.sentiment);
    final iconData = _getIconData(insight.icon);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: sentimentGradient.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sentimentColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: sentimentColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Gradient accent on the left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(gradient: sentimentGradient),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: sentimentGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: sentimentColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      iconData,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          insight.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (index * 100).ms)
        .slideX(begin: 0.2, duration: 500.ms, curve: Curves.easeOut)
        .fadeIn();
  }

  Color _getSentimentColor(InsightSentiment sentiment) {
    return switch (sentiment) {
      InsightSentiment.positive => AppColors.successGreen,
      InsightSentiment.neutral => AppColors.primaryBlue,
      InsightSentiment.warning => AppColors.warningOrange,
    };
  }

  LinearGradient _getSentimentGradient(InsightSentiment sentiment) {
    return switch (sentiment) {
      InsightSentiment.positive => AppColors.successGradient,
      InsightSentiment.neutral => AppColors.primaryGradient,
      InsightSentiment.warning => AppColors.warningGradient,
    };
  }

  IconData _getIconData(String iconName) {
    return switch (iconName) {
      'medication' => Icons.medication_rounded,
      'trending_up' => Icons.trending_up,
      'trending_down' => Icons.trending_down,
      'star' => Icons.star_rounded,
      'local_fire_department' => Icons.local_fire_department_rounded,
      'schedule' => Icons.schedule_rounded,
      'lightbulb' => Icons.lightbulb_rounded,
      _ => Icons.info_rounded,
    };
  }
}

extension on LinearGradient {
  LinearGradient withOpacity(double opacity) {
    return LinearGradient(
      colors: colors.map((color) => color.withOpacity(opacity)).toList(),
      begin: begin,
      end: end,
    );
  }
}
