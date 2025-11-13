import 'package:flutter/material.dart';

/// Permission/Health Status Banner
///
/// Displays important alerts and actionable banners for:
/// - Notification permissions
/// - Low stock warnings
/// - Timezone changes
/// - Health/system status
enum PermissionBannerType {
  warning, // Orange/amber background
  error, // Red background
  info, // Blue background
  success, // Green background
}

class PermissionBanner extends StatelessWidget { // Optional dismiss functionality

  const PermissionBanner({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onActionPressed,
    this.type = PermissionBannerType.warning,
    this.onDismiss,
    super.key,
  });
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onActionPressed;
  final PermissionBannerType type;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on banner type
    final bannerColors = _getBannerColors(colorScheme);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: bannerColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bannerColors.borderColor,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bannerColors.iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: bannerColors.iconColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: bannerColors.textColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Message
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: bannerColors.textColor.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Action button
                  FilledButton(
                    onPressed: onActionPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: bannerColors.buttonColor,
                      foregroundColor: bannerColors.buttonTextColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Optional dismiss button
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: bannerColors.textColor.withOpacity(0.6),
                ),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Dismiss',
              ),
            ],
          ],
        ),
      ),
    );
  }

  _BannerColors _getBannerColors(ColorScheme colorScheme) {
    switch (type) {
      case PermissionBannerType.warning:
        return _BannerColors(
          backgroundColor: Colors.amber.shade50,
          borderColor: Colors.amber.shade200,
          iconBackgroundColor: Colors.amber.shade100,
          iconColor: Colors.amber.shade700,
          textColor: Colors.amber.shade900,
          buttonColor: Colors.amber.shade600,
          buttonTextColor: Colors.white,
        );

      case PermissionBannerType.error:
        return _BannerColors(
          backgroundColor: colorScheme.errorContainer,
          borderColor: colorScheme.error.withOpacity(0.3),
          iconBackgroundColor: colorScheme.error.withOpacity(0.15),
          iconColor: colorScheme.error,
          textColor: colorScheme.onErrorContainer,
          buttonColor: colorScheme.error,
          buttonTextColor: colorScheme.onError,
        );

      case PermissionBannerType.info:
        return _BannerColors(
          backgroundColor: colorScheme.primaryContainer,
          borderColor: colorScheme.primary.withOpacity(0.3),
          iconBackgroundColor: colorScheme.primary.withOpacity(0.15),
          iconColor: colorScheme.primary,
          textColor: colorScheme.onPrimaryContainer,
          buttonColor: colorScheme.primary,
          buttonTextColor: colorScheme.onPrimary,
        );

      case PermissionBannerType.success:
        return _BannerColors(
          backgroundColor: colorScheme.secondaryContainer,
          borderColor: colorScheme.secondary.withOpacity(0.3),
          iconBackgroundColor: colorScheme.secondary.withOpacity(0.15),
          iconColor: colorScheme.secondary,
          textColor: colorScheme.onSecondaryContainer,
          buttonColor: colorScheme.secondary,
          buttonTextColor: colorScheme.onSecondary,
        );
    }
  }
}

/// Internal class to hold banner color configuration
class _BannerColors {

  _BannerColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.buttonColor,
    required this.buttonTextColor,
  });
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color buttonColor;
  final Color buttonTextColor;
}
