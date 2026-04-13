import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Circular checkmark shown inside `MedicineTypeCard` when the card is
/// selected. Animates in with a spring scale and fade.
class MedicineTypeCheckmark extends StatelessWidget {
  const MedicineTypeCheckmark({
    required this.iconColor,
    required this.bgColor,
    super.key,
  });

  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(Icons.check_rounded, color: iconColor, size: 16),
    ).animate().scale(duration: 300.ms, curve: Curves.elasticOut).fadeIn();
  }
}
