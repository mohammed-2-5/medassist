import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

/// Handles notification and alarm permission requests/checks.
class NotificationPermissions {
  NotificationPermissions._();

  /// Request notification and exact alarm permissions.
  static Future<bool> requestPermissions(
      FlutterLocalNotificationsPlugin notifications) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final notificationGranted =
          await android?.requestNotificationsPermission();
      debugPrint('📱 Notification permission: $notificationGranted');

      final exactAlarmGranted =
          await android?.requestExactAlarmsPermission();
      debugPrint('📱 Exact alarms permission: $exactAlarmGranted');

      if (exactAlarmGranted == false) {
        debugPrint(
            '⚠️ Exact alarms permission denied or needs to be granted in settings');
      }

      return (exactAlarmGranted ?? false) && (notificationGranted ?? false);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('iOS notification permission: $granted');
      return granted ?? false;
    }

    return false;
  }

  /// Request exact alarms permission specifically.
  static Future<bool> requestExactAlarms(
      FlutterLocalNotificationsPlugin notifications) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      debugPrint('📱 Requesting exact alarms permission...');
      final granted = await android?.requestExactAlarmsPermission();
      debugPrint('📱 Exact alarms permission result: $granted');

      return granted ?? false;
    }
    return true;
  }

  /// Check if notifications are enabled.
  static Future<bool> areNotificationsEnabled(
      FlutterLocalNotificationsPlugin notifications) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return true;
    }
    return false;
  }

  /// Check if exact alarms can be scheduled (Android 12+).
  static Future<bool> canScheduleExactAlarms(
      FlutterLocalNotificationsPlugin notifications) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final canSchedule =
          await android?.canScheduleExactNotifications() ?? false;
      debugPrint('📱 Can schedule exact alarms: $canSchedule');
      return canSchedule;
    }
    return true;
  }

  /// Check if battery optimization is disabled for the app.
  static Future<bool> isBatteryOptimizationDisabled() async {
    try {
      final status =
          await permission_handler.Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking battery optimization: $e');
      return true;
    }
  }
}
