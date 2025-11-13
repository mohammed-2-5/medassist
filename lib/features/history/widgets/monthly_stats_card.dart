import 'package:flutter/material.dart';
import 'package:med_assist/core/theme/app_animations.dart';
import 'package:med_assist/core/widgets/animated_card.dart';

/// Card showing monthly adherence statistics with smooth animations
class MonthlyStatsCard extends StatelessWidget {

  const MonthlyStatsCard({
    required this.stats,
    required this.month,
    super.key,
  });
  final Map<String, dynamic> stats;
  final String month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final adherenceRate = stats['adherenceRate'] as int;
    final takenDoses = stats['taken'] as int;
    final missedDoses = stats['missed'] as int;
    final totalDoses = stats['total'] as int;

    return AnimatedCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  month,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Adherence rate with progress indicator
            Row(
              children: [
                // Circular progress with animation
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: adherenceRate / 100),
                          duration: AppAnimations.slow,
                          curve: AppAnimations.smooth,
                          builder: (context, value, child) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 8,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getAdherenceColor(adherenceRate, colorScheme),
                              ),
                              strokeCap: StrokeCap.round,
                            );
                          },
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder<int>(
                            tween: IntTween(begin: 0, end: adherenceRate),
                            duration: AppAnimations.slow,
                            curve: AppAnimations.smooth,
                            builder: (context, value, child) {
                              return Text(
                                '$value%',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getAdherenceColor(adherenceRate, colorScheme),
                                ),
                              );
                            },
                          ),
                          Text(
                            'Rate',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Stats
                Expanded(
                  child: Column(
                    children: [
                      _buildStatRow(
                        context,
                        'Total Doses',
                        totalDoses.toString(),
                        Icons.medication,
                        colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        'Taken',
                        takenDoses.toString(),
                        Icons.check_circle,
                        colorScheme.secondary,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        'Missed',
                        missedDoses.toString(),
                        Icons.cancel,
                        colorScheme.error,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Adherence message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getAdherenceColor(adherenceRate, colorScheme)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getAdherenceIcon(adherenceRate),
                    color: _getAdherenceColor(adherenceRate, colorScheme),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getAdherenceMessage(adherenceRate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getAdherenceColor(adherenceRate, colorScheme),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getAdherenceColor(int rate, ColorScheme colorScheme) {
    if (rate >= 90) {
      return colorScheme.secondary; // Green
    } else if (rate >= 70) {
      return colorScheme.tertiary; // Orange/Yellow
    } else {
      return colorScheme.error; // Red
    }
  }

  IconData _getAdherenceIcon(int rate) {
    if (rate >= 90) {
      return Icons.emoji_events; // Trophy
    } else if (rate >= 70) {
      return Icons.trending_up;
    } else {
      return Icons.warning;
    }
  }

  String _getAdherenceMessage(int rate) {
    if (rate >= 90) {
      return 'Excellent adherence! Keep up the great work!';
    } else if (rate >= 80) {
      return 'Good adherence. Try to improve consistency.';
    } else if (rate >= 70) {
      return 'Fair adherence. Consider setting more reminders.';
    } else if (rate >= 50) {
      return 'Low adherence. Please try to take your medications regularly.';
    } else {
      return 'Very low adherence. Talk to your healthcare provider.';
    }
  }
}
