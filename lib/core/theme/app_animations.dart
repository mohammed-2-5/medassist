import 'package:flutter/animation.dart';

/// Modern animation configurations for smooth, professional UX
class AppAnimations {
  AppAnimations._();

  // Duration constants
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration verySlow = Duration(milliseconds: 500);

  // Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve spring = Curves.elasticInOut;

  // Page transitions
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOutQuart;

  // Card animations
  static const Duration cardScale = Duration(milliseconds: 200);
  static const Curve cardScaleCurve = Curves.easeOutQuart;

  // List animations
  static const Duration listItemStagger = Duration(milliseconds: 50);
  static const Duration listItemFade = Duration(milliseconds: 300);

  // Button animations
  static const Duration buttonScale = Duration(milliseconds: 100);
  static const Curve buttonScaleCurve = Curves.easeOut;

  // Shimmer loading
  static const Duration shimmer = Duration(milliseconds: 1500);
}
