import 'package:flutter/material.dart';
import 'package:med_assist/features/splash/constants/splash_palette.dart';

/// Sweeping conic-gradient ring drawn around the logo.
class ConicRingPainter extends CustomPainter {
  const ConicRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          SplashPalette.nebulaIndigo.withValues(alpha: 0),
          SplashPalette.nebulaViolet.withValues(alpha: 0.9),
          SplashPalette.accentLavender.withValues(alpha: 0.95),
          SplashPalette.accentCyan.withValues(alpha: 0.8),
          SplashPalette.nebulaIndigo.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.45, 0.65, 0.80, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
