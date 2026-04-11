import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_assist/services/notification/notification_channels.dart';
import 'package:med_assist/services/notification/notification_id_generator.dart';
import 'package:timezone/timezone.dart' as tz;

/// Schedules escalating recurring reminders for missed doses.
class NotificationRecurring {
  NotificationRecurring._();

  /// Schedule escalating recurring reminders for a missed dose.
  static Future<void> schedule(
    FlutterLocalNotificationsPlugin notifications, {
    required int medicationId,
    required int reminderIndex,
    required String medicationName,
    required String dose,
    required int intervalMinutes,
    int maxReminders = 4,
  }) async {
    debugPrint('📱 Scheduling recurring reminders for $medicationName');
    debugPrint('   → Interval: $intervalMinutes minutes');
    debugPrint('   → Max reminders: $maxReminders');

    await cancelForReminderTime(notifications, medicationId, reminderIndex);

    for (var i = 0; i < maxReminders; i++) {
      final escalationLevel = i + 1;
      final minutesFromNow = intervalMinutes * escalationLevel;
      final notificationId = NotificationIdGenerator.recurring(
          medicationId, reminderIndex, escalationLevel);

      await _scheduleSingle(
        notifications,
        id: notificationId,
        medicationId: medicationId,
        medicationName: medicationName,
        dose: dose,
        minutesFromNow: minutesFromNow,
        escalationLevel: escalationLevel,
      );
    }

    debugPrint(
        '✅ Scheduled $maxReminders recurring reminders for $medicationName');
  }

  static Future<void> _scheduleSingle(
    FlutterLocalNotificationsPlugin notifications, {
    required int id,
    required int medicationId,
    required String medicationName,
    required String dose,
    required int minutesFromNow,
    required int escalationLevel,
  }) async {
    final scheduledTime =
        DateTime.now().add(Duration(minutes: minutesFromNow));
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    debugPrint('⏰ Scheduling recurring reminder #$escalationLevel');
    debugPrint('   → Will fire in: $minutesFromNow minutes');

    final payload = json.encode({
      'type': 'recurring_reminder',
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dose': dose,
      'escalationLevel': escalationLevel,
    });

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationChannels.medicationChannelId,
        'Medication Reminders',
        channelDescription:
            'Recurring reminders for missed medication doses',
        importance: Importance.max,
        priority: Priority.max,
        icon: 'ic_notification',
        enableLights: true,
        color: Color(0xFFFF5722),
        ledColor: Color(0xFFFF5722),
        ledOnMs: 1000,
        ledOffMs: 500,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('take', 'Take Now'),
          AndroidNotificationAction('skip', 'Skip'),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'recurring_reminder',
      ),
    );

    await notifications.zonedSchedule(
      id,
      '⚠️ Missed Dose: $medicationName',
      "You haven't taken $dose yet. Please take it now. (Reminder #$escalationLevel)",
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint(
        '✅ Scheduled recurring reminder #$escalationLevel for $medicationName');
  }

  /// Cancel recurring reminders for a specific reminder time.
  static Future<void> cancelForReminderTime(
    FlutterLocalNotificationsPlugin notifications,
    int medicationId,
    int reminderIndex,
  ) async {
    for (var i = 1; i <= 10; i++) {
      await notifications.cancel(
          NotificationIdGenerator.recurring(medicationId, reminderIndex, i));
    }
  }

  /// Cancel all recurring reminders for a medication (all reminder times).
  static Future<void> cancelForMedication(
    FlutterLocalNotificationsPlugin notifications,
    int medicationId,
  ) async {
    for (var reminderIndex = 0; reminderIndex < 6; reminderIndex++) {
      for (var escalation = 1; escalation <= 10; escalation++) {
        await notifications.cancel(NotificationIdGenerator.recurring(
            medicationId, reminderIndex, escalation));
      }
    }
  }
}
