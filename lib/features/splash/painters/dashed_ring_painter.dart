import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Dashed ring — counter-rotates against the conic sweep.
class DashedRingPainter extends CustomPainter {
  const DashedRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final radius = size.width / 2 - 2;
    final center = size.center(Offset.zero);
    const dashCount = 48;
    const dashSweep = (2 * math.pi) / dashCount;
    for (var i = 0; i < dashCount; i += 2) {
      final start = i * dashSweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashSweep * 0.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
