import 'package:flutter/material.dart';
import 'package:med_assist/core/widgets/gradient_container.dart';

/// Animated stat item used in the stock summary card.
class StockStatItem extends StatelessWidget {
  const StockStatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.index,
    super.key,
  });

  final String label;
  final int value;
  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delay = index * 100;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          GradientContainer(
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(12),
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
            child: TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: Duration(milliseconds: 800 + delay),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, child) {
                return Text(
                  animValue.toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
