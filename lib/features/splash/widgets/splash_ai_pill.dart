import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/features/splash/constants/splash_palette.dart';

/// Translucent gradient pill displaying the AI title.
/// No BackdropFilter — gradient fill on top of the animated background reads
/// the same visually but doesn't trigger a per-frame blur pass.
class SplashAiPill extends StatelessWidget {
  const SplashAiPill({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          colors: [
            SplashPalette.nebulaIndigo.withValues(alpha: 0.55),
            SplashPalette.nebulaViolet.withValues(alpha: 0.40),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: SplashPalette.accentLavender.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: SplashPalette.accentLavender,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(label, style: textStyle),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 1300),
          duration: const Duration(milliseconds: 600),
        )
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          delay: const Duration(milliseconds: 1300),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
        );
  }
}
