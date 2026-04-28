import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:med_assist/features/splash/constants/splash_palette.dart';

/// Animated aurora — three drifting blobs over a midnight gradient.
/// The static background gradient is painted by the parent so we don't
/// rebuild that shader every frame.
class AuroraBackgroundPainter extends CustomPainter {
  AuroraBackgroundPainter({required this.progress});

  final double progress;

  // Pre-built radial shaders are not size-dependent in stops, so we cache
  // colors and create the shader cheaply per frame at the moving center.
  static final Color _violet =
      SplashPalette.nebulaViolet.withValues(alpha: 0.45);
  static final Color _indigo =
      SplashPalette.nebulaIndigo.withValues(alpha: 0.45);
  static final Color _ocean =
      SplashPalette.nebulaPink.withValues(alpha: 0.45);
  static const Color _transparent = Colors.transparent;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;
    _blob(
      canvas,
      size,
      Offset(0.25 + 0.10 * math.cos(t), 0.30 + 0.08 * math.sin(t)),
      _violet,
      0.55,
    );
    _blob(
      canvas,
      size,
      Offset(0.75 + 0.10 * math.sin(t * 0.8), 0.25 + 0.06 * math.cos(t * 1.2)),
      _indigo,
      0.50,
    );
    _blob(
      canvas,
      size,
      Offset(0.50 + 0.12 * math.sin(t * 1.4), 0.85 + 0.05 * math.cos(t)),
      _ocean,
      0.65,
    );
  }

  void _blob(
    Canvas canvas,
    Size size,
    Offset normalized,
    Color color,
    double radiusFactor,
  ) {
    final center =
        Offset(size.width * normalized.dx, size.height * normalized.dy);
    final radius = size.shortestSide * radiusFactor;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, _transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant AuroraBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
