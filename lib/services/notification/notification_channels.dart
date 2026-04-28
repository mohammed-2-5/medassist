import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Creates and manages Android notification channels.
///
/// Custom-sound channels are derived per-URI because Android channel sound is
/// immutable after creation: changing a sound = a new channel.
class NotificationChannels {
  NotificationChannels._();

  static const medicationChannelId = 'medication_reminders_v2';
  static const stockChannelId = 'stock_alerts';
  static const generalChannelId = 'general';

  /// Channel-id prefix used for per-URI medication channels.
  static const _customMedicationPrefix = 'medication_reminders_sound_';

  /// In-process cache to skip redundant channel creation.
  static final Set<String> _ensured = {};

  /// Create base notification channels for Android.
  static Future<void> createAll(
    FlutterLocalNotificationsPlugin notifications,
  ) async {
    const medicationChannel = AndroidNotificationChannel(
      medicationChannelId,
      'Medication Reminders',
      description: 'Notifications for scheduled medication doses',
      importance: Importance.max,
      enableLights: true,
      ledColor: Color(0xFF2196F3),
    );

    const stockChannel = AndroidNotificationChannel(
      stockChannelId,
      'Stock Alerts',
      description: 'Notifications for low medication stock',
    );

    const generalChannel = AndroidNotificationChannel(
      generalChannelId,
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.low,
    );

    final android = notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.createNotificationChannel(medicationChannel);
    await android?.createNotificationChannel(stockChannel);
    await android?.createNotificationChannel(generalChannel);

    _ensured
      ..add(medicationChannelId)
      ..add(stockChannelId)
      ..add(generalChannelId);

    debugPrint('Notification channels created');
  }

  /// Resolve the channel id to use for a medication reminder given a stored
  /// custom sound URI. Creates the channel on first use.
  ///
  /// Returns the base [medicationChannelId] when [uri] is null/empty.
  static Future<String> ensureMedicationChannelForSound(
    FlutterLocalNotificationsPlugin notifications,
    String? uri,
  ) async {
    if (uri == null || uri.isEmpty) return medicationChannelId;

    final channelId = '$_customMedicationPrefix${uri.hashCode.abs()}';
    if (_ensured.contains(channelId)) return channelId;

    final android = notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return medicationChannelId;

    final channel = AndroidNotificationChannel(
      channelId,
      'Medication Reminders (Custom Sound)',
      description: 'Reminders using a user-selected ringtone',
      importance: Importance.max,
      enableLights: true,
      ledColor: const Color(0xFF2196F3),
      sound: UriAndroidNotificationSound(uri),
    );
    await android.createNotificationChannel(channel);
    _ensured.add(channelId);
    debugPrint('Created custom-sound channel $channelId for $uri');
    return channelId;
  }
}
