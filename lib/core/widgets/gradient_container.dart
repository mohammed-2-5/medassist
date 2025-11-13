import 'package:flutter/material.dart';

/// Container with subtle gradient for visual depth
/// Adds modern, professional appearance
class GradientContainer extends StatelessWidget {

  const GradientContainer({
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderRadius,
    this.padding,
    this.elevation,
    super.key,
  });
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColors = colors ??
        [
          colorScheme.primaryContainer,
          colorScheme.primaryContainer.withValues(alpha: 0.7),
        ];

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: gradientColors,
        ),
        borderRadius: borderRadius,
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: elevation!,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Predefined gradient styles
class GradientStyle {
  static List<Color> primary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      colorScheme.primary,
      colorScheme.primary.withValues(alpha: 0.8),
    ];
  }

  static List<Color> secondary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      colorScheme.secondary,
      colorScheme.secondary.withValues(alpha: 0.8),
    ];
  }

  static List<Color> surface(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      colorScheme.surfaceContainerLow,
      colorScheme.surfaceContainer,
    ];
  }

  static List<Color> success(BuildContext context) {
    return [
      Colors.green.shade400,
      Colors.green.shade600,
    ];
  }

  static List<Color> warning(BuildContext context) {
    return [
      Colors.orange.shade400,
      Colors.orange.shade600,
    ];
  }

  static List<Color> error(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      colorScheme.error,
      colorScheme.error.withValues(alpha: 0.8),
    ];
  }
}
