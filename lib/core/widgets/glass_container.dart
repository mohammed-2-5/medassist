import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium Glass Container with Blur Effect
///
/// Features:
/// - Frosted glass blur effect (glassmorphism)
/// - Gradient borders
/// - Customizable opacity and blur intensity
/// - Perfect for navigation bars and premium overlays
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    this.width,
    this.height,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderRadius = 16.0,
    this.border,
    this.gradient,
    this.padding,
    this.margin,
    super.key,
  });

  final Widget child;
  final double? width;
  final double? height;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Border? border;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Default gradient border if none provided
    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.5),
            colorScheme.secondary.withOpacity(0.5),
          ],
        );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface.withOpacity(opacity),
                  colorScheme.surface.withOpacity(opacity * 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                width: 1.5,
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Animated Glass Card with Hover Effect
///
/// Perfect for premium cards with glassmorphism effect
class AnimatedGlassCard extends StatefulWidget {
  const AnimatedGlassCard({
    required this.child,
    this.onTap,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.elevation = 2.0,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              blur: widget.blur,
              opacity: widget.opacity,
              borderRadius: widget.borderRadius,
              padding: widget.padding,
              margin: widget.margin,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Gradient Border Container
///
/// Creates a container with an animated gradient border
class GradientBorderContainer extends StatelessWidget {
  const GradientBorderContainer({
    required this.child,
    this.gradient,
    this.borderRadius = 16.0,
    this.borderWidth = 2.0,
    this.padding,
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final Gradient? gradient;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.tertiary,
          ],
        );

    return Container(
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: child,
      ),
    );
  }
}
