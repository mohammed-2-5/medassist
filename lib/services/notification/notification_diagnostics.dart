import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_assist/services/notification/notification_channels.dart';
import 'package:med_assist/services/notification/notification_permissions.dart';
import 'package:timezone/timezone.dart' as tz;

/// Notification diagnostics, settings launchers, and test utilities.
class NotificationDiagnostics {
  NotificationDiagnostics._();

  /// Show test notification immediately.
  static Future<void> showTestNotification(
      FlutterLocalNotificationsPlugin notifications) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationChannels.generalChannelId,
        'General Notifications',
        channelDescription: 'General app notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notification',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await notifications.show(
      999999,
      'Test Notification',
      'Notifications are working correctly!',
      details,
    );

    final pending = await notifications.pendingNotificationRequests();
    debugPrint('Pending after test notification: ${pending.length}');
  }

  /// Schedule a test notification for 1 minute from now.
  static Future<void> scheduleTestIn1Minute(
      FlutterLocalNotificationsPlugin notifications) async {
    final now = DateTime.now();
    final scheduledTime = now.add(const Duration(minutes: 1));
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    debugPrint(
        '⏰ Scheduling test notification for: ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}');

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationChannels.medicationChannelId,
        'Medication Reminders',
        channelDescription: 'Test scheduled notification',
        importance: Importance.max,
        priority: Priority.max,
        icon: 'ic_notification',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await notifications.zonedSchedule(
      888888,
      'Test Scheduled Notification',
      'This should appear in 1 minute! Time: ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}',
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('✅ Test notification scheduled for 1 minute from now');
  }

  /// Get detailed notification diagnostics.
  static Future<Map<String, dynamic>> getDiagnostics(
      FlutterLocalNotificationsPlugin notifications) async {
    final pending = await notifications.pendingNotificationRequests();
    final notificationsEnabled =
        await NotificationPermissions.areNotificationsEnabled(notifications);
    final canScheduleExact =
        await NotificationPermissions.canScheduleExactAlarms(notifications);
    final now = DateTime.now();

    final diagnostics = {
      'notificationsEnabled': notificationsEnabled,
      'canScheduleExactAlarms': canScheduleExact,
      'pendingNotificationsCount': pending.length,
      'pendingNotifications': pending
          .map((p) => {
                'id': p.id,
                'title': p.title,
                'body': p.body,
                'payload': p.payload,
              })
          .toList(),
      'channelsCreated': true,
      'timezoneConfigured': tz.local.name,
      'deviceTime': now.toString(),
      'deviceTimeHour': now.hour,
      'deviceTimeMinute': now.minute,
    };

    debugPrint('=== NOTIFICATION DIAGNOSTICS ===');
    debugPrint('Notifications Enabled: $notificationsEnabled');
    debugPrint('Can Schedule Exact Alarms: $canScheduleExact');
    debugPrint('Pending Notifications: ${pending.length}');
    debugPrint('Timezone: ${tz.local.name}');
    debugPrint(
        'Device Time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    for (final p in pending) {
      debugPrint('  - ID: ${p.id}, Title: ${p.title}, Body: ${p.body}');
    }
    debugPrint('================================');

    return diagnostics;
  }

  /// Open exact alarm settings.
  static Future<void> openExactAlarmSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    await intent.launch();
  }

  /// Open notification channel settings.
  static Future<void> openChannelSettings(
      {String channelId = NotificationChannels.medicationChannelId}) async {
    const intent = AndroidIntent(
      action: 'android.settings.CHANNEL_NOTIFICATION_SETTINGS',
      arguments: <String, dynamic>{
        'android.provider.extra.APP_PACKAGE': 'com.example.med_assist',
        'android.provider.extra.CHANNEL_ID':
            NotificationChannels.medicationChannelId,
      },
    );
    await intent.launch();
  }

  /// Open medication reminder sound settings.
  static Future<void> openMedicationReminderSoundSettings() async {
    await openChannelSettings();
  }

  /// Request battery optimization exemption.
  static Future<void> requestBatteryOptimizationExemption() async {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
      data: 'package:com.example.med_assist',
    );
    await intent.launch();
  }

  /// Open app notification settings.
  static Future<void> openAppNotificationSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.APP_NOTIFICATION_SETTINGS',
      arguments: <String, dynamic>{
        'android.provider.extra.APP_PACKAGE': 'com.example.med_assist',
      },
    );
    await intent.launch();
  }
}
