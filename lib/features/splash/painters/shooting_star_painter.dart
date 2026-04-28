import 'package:flutter/material.dart';

/// One shooting-star streak per cycle. No mask blur for performance.
class ShootingStarPainter extends CustomPainter {
  ShootingStarPainter({required this.progress});

  final double progress;

  static const _visibleWindow = 0.25;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress > _visibleWindow) return;
    final t = progress / _visibleWindow;

    final startX = size.width * 0.15;
    final startY = size.height * 0.18;
    final length = size.width * 0.45;

    final head = Offset(startX + length * t, startY + length * t * 0.4);
    final tail = Offset(head.dx - 90, head.dy - 36);

    final fade = (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.85 * fade),
        ],
      ).createShader(Rect.fromPoints(tail, head))
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tail, head, paint);

    canvas.drawCircle(
      head,
      2.5,
      Paint()..color = Colors.white.withValues(alpha: fade),
    );
  }

  @override
  bool shouldRepaint(covariant ShootingStarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
