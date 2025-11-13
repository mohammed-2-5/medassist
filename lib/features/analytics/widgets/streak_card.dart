import 'package:flutter/material.dart';
import 'package:med_assist/core/widgets/animated_card.dart';
import 'package:med_assist/core/widgets/gradient_container.dart';

/// Card widget displaying the current adherence streak with animations
class StreakCard extends StatefulWidget {

  const StreakCard({
    required this.streak,
    super.key,
  });
  final int streak;

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedCard(
      onTap: () {},
      child: Row(
        children: [
          // Fire icon with pulse animation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: child,
              );
            },
            child: GradientContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(50),
              elevation: 4,
              colors: [
                colorScheme.secondary,
                colorScheme.tertiary,
              ],
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: widget.streak),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          '$value',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.streak == 1 ? 'day' : 'days',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getStreakMessage(widget.streak),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Trophy badge for milestones with bounce animation
          if (widget.streak >= 7) ...[
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMilestoneColor(widget.streak, colorScheme)
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: _getMilestoneColor(widget.streak, colorScheme),
                  size: 32,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStreakMessage(int streak) {
    if (streak == 0) {
      return 'Start your streak today!';
    } else if (streak < 7) {
      return 'Keep it up! ${7 - streak} more ${7 - streak == 1 ? 'day' : 'days'} to a week!';
    } else if (streak < 30) {
      return 'Amazing! ${30 - streak} more ${30 - streak == 1 ? 'day' : 'days'} to a month!';
    } else if (streak < 100) {
      return 'Incredible! ${100 - streak} more ${100 - streak == 1 ? 'day' : 'days'} to 100!';
    } else {
      return "You're a medication adherence champion!";
    }
  }

  Color _getMilestoneColor(int streak, ColorScheme colorScheme) {
    if (streak >= 100) {
      return Colors.purple;
    } else if (streak >= 30) {
      return Colors.amber;
    } else if (streak >= 7) {
      return colorScheme.secondary;
    } else {
      return colorScheme.primary;
    }
  }
}
