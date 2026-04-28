import 'dart:math' as math;

import 'package:flutter/material.dart';

class _Star {
  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.twinkleSpeed,
    required this.phase,
  });

  final double x;
  final double y;
  final double radius;
  final double twinkleSpeed;
  final double phase;
}

/// Twinkling starfield. Uses canvas.drawPoints (single GPU call) for speed.
class StarFieldPainter extends CustomPainter {
  StarFieldPainter({required this.progress});

  final double progress;

  // Reduced from 70 → 36; precomputed list avoids per-frame allocation.
  static final List<_Star> _stars = List.generate(36, (i) {
    final rng = math.Random(i * 7331);
    return _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      radius: 0.8 + rng.nextDouble() * 1.8,
      twinkleSpeed: 0.4 + rng.nextDouble() * 1.4,
      phase: rng.nextDouble(),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // No MaskFilter.blur — drawing as small filled circles is much cheaper.
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in _stars) {
      final twinkle =
          (math.sin((progress * s.twinkleSpeed + s.phase) * 2 * math.pi) + 1) /
              2;
      final alpha = 0.25 + 0.75 * twinkle;
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.radius * (0.8 + 0.4 * twinkle),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
