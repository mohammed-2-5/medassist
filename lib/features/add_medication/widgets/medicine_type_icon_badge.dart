import 'package:flutter/material.dart';

/// Circular emoji badge used inside `MedicineTypeCard`. Scales in with an
/// elastic spring when the host card becomes selected.
class MedicineTypeIconBadge extends StatelessWidget {
  const MedicineTypeIconBadge({
    required this.emoji,
    required this.isSelected,
    required this.colorScheme,
    super.key,
  });

  final String emoji;
  final bool isSelected;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0, end: isSelected ? 1.0 : 0.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(
        scale: 1.0 + (value * 0.15),
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.onPrimary.withValues(alpha: 0.2)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: colorScheme.onPrimary.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 36)),
      ),
    );
  }
}
