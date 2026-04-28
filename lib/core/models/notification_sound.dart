import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Model for a notification sound choice.
///
/// Two flavors:
/// - [defaultSound]: system default notification tone (uri == null)
/// - Custom: user-picked via native ringtone picker (uri = content://...)
@immutable
class NotificationSound {
  const NotificationSound({
    required this.id,
    required this.name,
    this.uri,
    this.icon,
  });

  /// Build a custom sound from a picker result.
  factory NotificationSound.fromUri(String uri, {String? title}) {
    return NotificationSound(
      id: 'custom:${uri.hashCode}',
      name: title ?? 'Custom',
      uri: uri,
      icon: Icons.music_note,
    );
  }

  /// Restore from a stored URI (e.g. medication.customSoundPath).
  factory NotificationSound.fromStoredPath(
    String? path, {
    String? cachedTitle,
  }) {
    if (path == null || path.isEmpty) return defaultSound;
    return NotificationSound.fromUri(path, title: cachedTitle);
  }

  /// Stable id for equality. `'default'` for system default,
  /// `'custom:<hash>'` for picked URIs.
  final String id;

  /// Display title (system default label or the picked ringtone's title).
  final String name;

  /// Storage path. `null` = system default.
  /// Format on Android: `content://media/...` from RingtoneManager.
  final String? uri;

  /// Optional icon override.
  final IconData? icon;

  bool get isDefault => uri == null;

  /// System default notification sound — always available, no permission.
  static const NotificationSound defaultSound = NotificationSound(
    id: 'default',
    name: 'Default',
    icon: Icons.notifications_active,
  );

  NotificationSound copyWith({String? name}) {
    return NotificationSound(
      id: id,
      name: name ?? this.name,
      uri: uri,
      icon: icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSound &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
