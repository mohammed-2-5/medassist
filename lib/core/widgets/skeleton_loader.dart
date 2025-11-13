import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loading widgets with shimmer effect
class SkeletonLoader {
  SkeletonLoader._();

  /// Generic shimmer wrapper
  static Widget _shimmer({
    required Widget child,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: child,
    );
  }

  /// Skeleton box (for images, icons, etc.)
  static Widget box({
    required BuildContext context,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return _shimmer(
      context: context,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Skeleton text line
  static Widget text({
    required BuildContext context,
    double? width,
    double height = 16,
  }) {
    return _shimmer(
      context: context,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Skeleton card (like medication card)
  static Widget card({
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                box(
                  context: context,
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(context: context, width: 150),
                      const SizedBox(height: 8),
                      text(context: context, width: 100, height: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            text(context: context, width: double.infinity, height: 14),
          ],
        ),
      ),
    );
  }

  /// Skeleton list (multiple cards)
  static Widget list({
    required BuildContext context,
    int itemCount = 5,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => card(context: context),
    );
  }

  /// Skeleton for stats card
  static Widget statsCard({
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                box(
                  context: context,
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.circular(30),
                ),
                const SizedBox(height: 12),
                text(context: context, width: 60, height: 12),
              ],
            ),
            Column(
              children: [
                box(
                  context: context,
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.circular(30),
                ),
                const SizedBox(height: 12),
                text(context: context, width: 60, height: 12),
              ],
            ),
            Column(
              children: [
                box(
                  context: context,
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.circular(30),
                ),
                const SizedBox(height: 12),
                text(context: context, width: 60, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton for chart
  static Widget chart({
    required BuildContext context,
    double height = 200,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text(context: context, width: 120, height: 18),
            const SizedBox(height: 16),
            box(
              context: context,
              width: double.infinity,
              height: height,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      ),
    );
  }
}
