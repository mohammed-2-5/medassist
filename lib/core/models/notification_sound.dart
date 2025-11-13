import 'package:flutter/material.dart';

/// Model for notification sounds
class NotificationSound {

  const NotificationSound({
    required this.id,
    required this.name,
    required this.icon, required this.description, this.path,
  });
  final String id;
  final String name;
  final String? path; // null for default system sound
  final IconData icon;
  final String description;

  bool get isDefault => path == null;
  bool get isCustom => id == 'custom';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSound &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Built-in notification sounds
  /// Note: All use system notification sound for reliability
  /// Different options provided for user clarity/preference
  static const List<NotificationSound> presets = [
    NotificationSound(
      id: 'default',
      name: 'Default',
      icon: Icons.notifications,
      description: 'System default notification sound',
    ),
    NotificationSound(
      id: 'notification',
      name: 'Notification',
      icon: Icons.notifications_outlined,
      description: 'Standard notification tone',
    ),
    NotificationSound(
      id: 'reminder',
      name: 'Reminder',
      icon: Icons.alarm,
      description: 'Reminder notification',
    ),
    NotificationSound(
      id: 'alert',
      name: 'Alert',
      icon: Icons.notification_important,
      description: 'Alert notification',
    ),
  ];

  /// Find a sound by ID
  static NotificationSound fromId(String? id) {
    if (id == null || id.isEmpty) {
      return presets.first; // Return default
    }

    return presets.firstWhere(
      (sound) => sound.id == id,
      orElse: () => presets.first,
    );
  }

  /// Find a sound by path
  static NotificationSound? fromPath(String? path) {
    if (path == null || path.isEmpty) {
      return presets.first; // Return default
    }

    return presets.firstWhere(
      (sound) => sound.path == path,
      orElse: () => presets.first,
    );
  }
}
