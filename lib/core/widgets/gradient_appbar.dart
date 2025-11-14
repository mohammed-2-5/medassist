import 'package:flutter/material.dart';

/// Premium Gradient AppBar Widget
///
/// A beautiful AppBar with gradient background, smooth shadows,
/// and optional glassmorphism effect.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    required this.title,
    this.gradient,
    this.actions,
    this.leading,
    this.elevation,
    this.centerTitle = true,
    this.titleStyle,
    super.key,
  });

  final Widget title;
  final Gradient? gradient;
  final List<Widget>? actions;
  final Widget? leading;
  final double? elevation;
  final bool centerTitle;
  final TextStyle? titleStyle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Default gradient if none provided
    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        );

    return Container(
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: DefaultTextStyle(
          style: titleStyle ??
              theme.textTheme.titleLarge!.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
          child: title,
        ),
        leading: leading,
        actions: actions,
        centerTitle: centerTitle,
        elevation: elevation ?? 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
    );
  }
}

/// Premium Sliver Gradient AppBar
///
/// For scrollable screens with parallax effects
class SliverGradientAppBar extends StatelessWidget {
  const SliverGradientAppBar({
    required this.title,
    this.gradient,
    this.actions,
    this.leading,
    this.expandedHeight = 200.0,
    this.flexibleSpace,
    this.pinned = true,
    this.floating = false,
    super.key,
  });

  final Widget title;
  final Gradient? gradient;
  final List<Widget>? actions;
  final Widget? leading;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final bool pinned;
  final bool floating;

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
          ],
        );

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onPrimary,
      leading: leading,
      title: title,
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: flexibleSpace,
      ),
    );
  }
}
