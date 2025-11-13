import 'package:flutter/material.dart';

/// Banner widget to show important app-level notifications
/// Used for notification permissions, deleted items, etc.
class ErrorBanner extends StatelessWidget {

  const ErrorBanner({
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor,
    this.onAction,
    this.actionLabel,
    this.onDismiss,
    super.key,
  });

  /// Banner for disabled notifications
  factory ErrorBanner.notificationsDisabled({
    required VoidCallback onAction,
    VoidCallback? onDismiss,
  }) {
    return ErrorBanner(
      message: 'Notifications are disabled. Enable them to receive medication reminders.',
      icon: Icons.notifications_off,
      actionLabel: 'Enable',
      onAction: onAction,
      onDismiss: onDismiss,
    );
  }

  /// Banner for deleted medication
  factory ErrorBanner.medicationDeleted({
    required String medicationName,
    VoidCallback? onDismiss,
  }) {
    return ErrorBanner(
      message: '$medicationName has been deleted.',
      icon: Icons.delete_outline,
      onDismiss: onDismiss,
    );
  }

  /// Banner for low stock warning
  factory ErrorBanner.lowStock({
    required String medicationName,
    required int remainingDoses,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) {
    return ErrorBanner(
      message: '$medicationName is running low ($remainingDoses doses left).',
      icon: Icons.inventory_2_outlined,
      actionLabel: 'Update Stock',
      onAction: onAction,
      onDismiss: onDismiss,
    );
  }
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final VoidCallback? onAction;
  final String? actionLabel;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: backgroundColor ?? colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: colorScheme.onErrorContainer,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onErrorContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close),
                color: colorScheme.onErrorContainer,
                iconSize: 20,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Provider for showing/hiding error banners
class ErrorBannerController extends ChangeNotifier {
  bool _showNotificationBanner = false;
  bool _showDeletedBanner = false;
  String? _deletedMedicationName;

  bool get showNotificationBanner => _showNotificationBanner;
  bool get showDeletedBanner => _showDeletedBanner;
  String? get deletedMedicationName => _deletedMedicationName;

  void showNotificationWarning() {
    _showNotificationBanner = true;
    notifyListeners();
  }

  void hideNotificationWarning() {
    _showNotificationBanner = false;
    notifyListeners();
  }

  void showMedicationDeleted(String medicationName) {
    _showDeletedBanner = true;
    _deletedMedicationName = medicationName;
    notifyListeners();

    // Auto-hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), hideDeletedBanner);
  }

  void hideDeletedBanner() {
    _showDeletedBanner = false;
    _deletedMedicationName = null;
    notifyListeners();
  }
}
