import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:med_assist/features/splash/constants/splash_palette.dart';

/// Three-dot pulsing loader rendered with a single ticker.
class SplashDotLoader extends StatefulWidget {
  const SplashDotLoader({super.key});

  @override
  State<SplashDotLoader> createState() => _SplashDotLoaderState();
}

class _SplashDotLoaderState extends State<SplashDotLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, _buildDot),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final phase = (_controller.value + index * 0.15) % 1.0;
    final wave = (math.sin(phase * 2 * math.pi) + 1) / 2;
    final scale = 0.6 + 0.6 * wave;
    final alpha = 0.4 + 0.6 * wave;
    final color = Color.lerp(
      SplashPalette.accentLavender,
      SplashPalette.accentCyan,
      wave,
    )!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: alpha),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: alpha * 0.7),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
