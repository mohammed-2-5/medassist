import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:med_assist/features/splash/constants/splash_palette.dart';
import 'package:med_assist/features/splash/painters/aurora_background_painter.dart';
import 'package:med_assist/features/splash/painters/shooting_star_painter.dart';
import 'package:med_assist/features/splash/painters/star_field_painter.dart';

/// Animated midnight backdrop. A single ticker drives all layers at ~30fps
/// (every 2nd frame) which is plenty for ambient motion and halves GPU load.
class SplashBackground extends StatefulWidget {
  const SplashBackground({super.key});

  @override
  State<SplashBackground> createState() => _SplashBackgroundState();
}

class _SplashBackgroundState extends State<SplashBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _t = 0;
  int _frame = 0;

  // Cycle lengths in milliseconds.
  static const int _auroraMs = 14000;
  static const int _starsMs = 6000;
  static const int _cometsMs = 7000;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    _frame++;
    if (_frame.isOdd) return; // ~30fps
    setState(() {
      _t = elapsed.inMicroseconds / 1000.0;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auroraP = (_t % _auroraMs) / _auroraMs;
    final starsP = (_t % _starsMs) / _starsMs;
    final cometsP = (_t % _cometsMs) / _cometsMs;
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: SplashPalette.backdrop),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: AuroraBackgroundPainter(progress: auroraP),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: StarFieldPainter(progress: starsP),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: ShootingStarPainter(progress: cometsP),
          ),
        ),
      ],
    );
  }
}
