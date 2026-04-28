import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/features/splash/constants/splash_palette.dart';
import 'package:med_assist/features/splash/painters/conic_ring_painter.dart';
import 'package:med_assist/features/splash/painters/dashed_ring_painter.dart';

/// Logo disc with rotating sweep ring, dashed counter-ring and pulsing halo.
/// One controller drives both ring rotation and halo pulse (sin curve), so
/// only one Ticker is registered for this widget.
class SplashLogoEmblem extends StatefulWidget {
  const SplashLogoEmblem({required this.diameter, super.key});

  final double diameter;

  @override
  State<SplashLogoEmblem> createState() => _SplashLogoEmblemState();
}

class _SplashLogoEmblemState extends State<SplashLogoEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outer = widget.diameter;
    final disc = outer * 0.68;
    return SizedBox(
      width: outer,
      height: outer,
      child: RepaintBoundary(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildHalo(outer),
            _buildRotatingRing(outer, const ConicRingPainter()),
            _buildRotatingRing(
              outer * 0.82,
              const DashedRingPainter(),
              reverse: true,
            ),
            _buildDisc(disc),
          ],
        ),
      ),
    );
  }

  Widget _buildHalo(double size) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        // Pulse derived from the same ticker — sin gives smooth in/out.
        final v = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                SplashPalette.nebulaIndigo.withValues(alpha: 0.30 + 0.18 * v),
                SplashPalette.nebulaIndigo.withValues(alpha: 0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRotatingRing(
    double size,
    CustomPainter painter, {
    bool reverse = false,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.rotate(
        angle: (reverse ? -1 : 1) * _controller.value * 2 * math.pi,
        child: child,
      ),
      child: RepaintBoundary(
        child: CustomPaint(size: Size.square(size), painter: painter),
      ),
    );
  }

  /// Solid translucent disc — no BackdropFilter (blur over animated content
  /// every frame is the single biggest perf cost on splash).
  Widget _buildDisc(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: SplashPalette.nebulaIndigo.withValues(alpha: 0.55),
            blurRadius: 36,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Image.asset('assets/logo1.png', fit: BoxFit.contain),
    )
        .animate()
        .scale(
          begin: const Offset(0.4, 0.4),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: const Duration(milliseconds: 600));
  }
}
