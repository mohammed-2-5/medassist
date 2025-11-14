import 'package:flutter/material.dart';

/// Premium Animated Progress Bar with Gradient
///
/// Features:
/// - Smooth animated progress changes
/// - Gradient fill with customizable colors
/// - Glow effect for critical levels
/// - Rounded corners for modern look
class AnimatedProgressBar extends StatefulWidget {
  const AnimatedProgressBar({
    required this.value,
    this.height = 8.0,
    this.borderRadius = 8.0,
    this.gradient,
    this.backgroundColor,
    this.showGlow = false,
    this.glowColor,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final double value; // 0.0 to 1.0
  final double height;
  final double borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool showGlow;
  final Color? glowColor;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getGradientColorAtValue(double value) {
    if (value > 0.5) {
      return Colors.green;
    } else if (value > 0.2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor =
        widget.backgroundColor ?? colorScheme.surfaceContainerHighest;

    final effectiveGradient = widget.gradient ??
        LinearGradient(
          colors: [
            _getGradientColorAtValue(widget.value),
            _getGradientColorAtValue(widget.value).withOpacity(0.7),
          ],
        );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Stack(
            children: [
              // Progress fill
              FractionallySizedBox(
                widthFactor: _animation.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: effectiveGradient,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    boxShadow: widget.showGlow
                        ? [
                            BoxShadow(
                              color: (widget.glowColor ??
                                      _getGradientColorAtValue(widget.value))
                                  .withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Circular Animated Progress Indicator with Gradient
class AnimatedCircularProgress extends StatefulWidget {
  const AnimatedCircularProgress({
    required this.value,
    this.size = 100.0,
    this.strokeWidth = 8.0,
    this.gradient,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 800),
    this.showPercentage = true,
    super.key,
  });

  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Duration duration;
  final bool showPercentage;

  @override
  State<AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: widget.backgroundColor ??
                      colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.backgroundColor ??
                        colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              // Progress circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              // Percentage text
              if (widget.showPercentage)
                Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
