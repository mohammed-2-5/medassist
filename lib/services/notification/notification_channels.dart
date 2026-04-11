import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Creates and manages Android notification channels.
class NotificationChannels {
  NotificationChannels._();

  static const medicationChannelId = 'medication_reminders_v2';
  static const stockChannelId = 'stock_alerts';
  static const generalChannelId = 'general';

  /// Create all notification channels for Android.
  static Future<void> createAll(
      FlutterLocalNotificationsPlugin notifications) async {
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

    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(medicationChannel);
    await android?.createNotificationChannel(stockChannel);
    await android?.createNotificationChannel(generalChannel);

    debugPrint('Notification channels created');
  }
}
