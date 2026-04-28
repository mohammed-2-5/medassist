import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/repetition_pattern_utils.dart';
import 'package:med_assist/services/notification/notification_channels.dart';
import 'package:med_assist/services/notification/notification_id_generator.dart';
import 'package:timezone/timezone.dart' as tz;

/// Handles scheduling and cancelling medication dose reminders.
class NotificationScheduler {
  NotificationScheduler._();

  /// Schedule all reminders for a medication using pattern-aware scheduling.
  static Future<void> scheduleForMedication(
    FlutterLocalNotificationsPlugin notifications,
    Medication medication,
    List<ReminderTime> reminderTimes,
  ) async {
    if (!medication.isActive) {
      debugPrint(
        'Medication ${medication.id} is not active, skipping reminders',
      );
      return;
    }

    await cancelForMedication(notifications, medication.id);
    final channelId =
        await NotificationChannels.ensureMedicationChannelForSound(
          notifications,
          medication.customSoundPath,
        );
    await _schedulePatternAware(
      notifications,
      medication,
      reminderTimes,
      channelId: channelId,
      soundUri: medication.customSoundPath,
    );

    final pending = await notifications.pendingNotificationRequests();
    debugPrint('Pending after scheduling dose reminder: ${pending.length}');
    debugPrint(
      'Scheduled reminders for ${medication.medicineName} (pattern: ${medication.repetitionPattern})',
    );
  }

  /// Schedule notifications only on days matching the repetition pattern.
  /// Schedules for the next 7 matching days then relies on the background
  /// service to reschedule weekly.
  static Future<void> _schedulePatternAware(
    FlutterLocalNotificationsPlugin notifications,
    Medication medication,
    List<ReminderTime> reminderTimes, {
    required String channelId,
    required String? soundUri,
  }) async {
    final now = DateTime.now();
    final endDate = medication.startDate.add(
      Duration(days: medication.durationDays),
    );
    var scheduled = 0;

    for (var dayOffset = 0; dayOffset < 30 && scheduled < 7; dayOffset++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: dayOffset));
      if (date.isAfter(endDate)) break;

      final isDoseDay = RepetitionPatternUtils.isDoseDay(
        pattern: medication.repetitionPattern,
        specificDaysOfWeek: medication.specificDaysOfWeek,
        startDate: medication.startDate,
        date: date,
        intervalDays: medication.intervalDays,
        intervalWeeks: medication.intervalWeeks,
        intervalMonths: medication.intervalMonths,
        dayOfMonth: medication.dayOfMonth,
      );
      if (!isDoseDay) continue;

      for (var i = 0; i < reminderTimes.length; i++) {
        final rt = reminderTimes[i];
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          rt.hour,
          rt.minute,
        );
        if (scheduledTime.isBefore(now)) continue;

        final notificationId = NotificationIdGenerator.patternAware(
          medication.id,
          scheduled,
          i,
        );
        final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

        final payload = json.encode({
          'type': 'medication_reminder',
          'medicationId': medication.id,
          'medicationName': medication.medicineName,
          'dose': '${medication.dosePerTime} ${medication.doseUnit}',
          'scheduledHour': rt.hour,
          'scheduledMinute': rt.minute,
        });

        await notifications.zonedSchedule(
          notificationId,
          'Time to take ${medication.medicineName}',
          'Take ${medication.dosePerTime} ${medication.doseUnit} now',
          tzTime,
          _medicationNotificationDetails(
            channelId: channelId,
            soundUri: soundUri,
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );

        debugPrint(
          '⏰ Scheduled pattern reminder: ${medication.medicineName} on ${date.toIso8601String()} at ${rt.hour}:${rt.minute}',
        );
      }
      scheduled++;
    }
    debugPrint(
      '✅ Scheduled $scheduled days of pattern-aware reminders for ${medication.medicineName}',
    );
  }

  /// Schedule a snooze notification.
  static Future<void> snooze(
    FlutterLocalNotificationsPlugin notifications, {
    required int medicationId,
    required String medicationName,
    required String dose,
    required int minutes,
    required int scheduledHour,
    required int scheduledMinute,
    String? customSoundUri,
  }) async {
    final snoozeId = NotificationIdGenerator.snooze(medicationId);
    await notifications.cancel(snoozeId);

    final tzSnoozeTime = tz.TZDateTime.from(
      DateTime.now().add(Duration(minutes: minutes)),
      tz.local,
    );

    final payload = json.encode({
      'type': 'snoozed_reminder',
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dose': dose,
      'scheduledHour': scheduledHour,
      'scheduledMinute': scheduledMinute,
    });

    final channelId =
        await NotificationChannels.ensureMedicationChannelForSound(
          notifications,
          customSoundUri,
        );
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'Medication Reminders',
        channelDescription: 'Notifications for scheduled medication doses',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notification',
        sound: customSoundUri != null && customSoundUri.isNotEmpty
            ? UriAndroidNotificationSound(customSoundUri)
            : null,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await notifications.zonedSchedule(
      snoozeId,
      'Reminder: Take $medicationName',
      'Take $dose now (Snoozed)',
      tzSnoozeTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint('Snoozed reminder for $medicationName for $minutes minutes');
  }

  /// Cancel all reminders for a medication.
  static Future<void> cancelForMedication(
    FlutterLocalNotificationsPlugin notifications,
    int medicationId,
  ) async {
    // Cancel reminder time slots (0-5)
    for (var i = 0; i < 6; i++) {
      await notifications.cancel(
        NotificationIdGenerator.reminder(medicationId, i),
      );
    }

    // Cancel pattern-aware reminders (up to 7 days * 6 reminders)
    for (var i = 0; i < 70; i++) {
      await notifications.cancel(medicationId * 1000 + i);
    }

    // Cancel low stock, expiry, snooze
    await notifications.cancel(NotificationIdGenerator.lowStock(medicationId));
    await notifications.cancel(NotificationIdGenerator.expiry(medicationId));
    await notifications.cancel(NotificationIdGenerator.snooze(medicationId));

    // Cancel all recurring reminders
    for (var reminderIndex = 0; reminderIndex < 6; reminderIndex++) {
      for (var escalation = 1; escalation <= 10; escalation++) {
        await notifications.cancel(
          NotificationIdGenerator.recurring(
            medicationId,
            reminderIndex,
            escalation,
          ),
        );
      }
    }

    debugPrint('Cancelled all reminders for medication $medicationId');
  }

  static NotificationDetails _medicationNotificationDetails({
    required String channelId,
    required String? soundUri,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'Medication Reminders',
        channelDescription: 'Notifications for scheduled medication doses',
        importance: Importance.max,
        priority: Priority.max,
        icon: 'ic_notification',
        enableLights: true,
        color: const Color(0xFF2196F3),
        ledColor: const Color(0xFF2196F3),
        ledOnMs: 1000,
        ledOffMs: 500,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        sound: soundUri != null && soundUri.isNotEmpty
            ? UriAndroidNotificationSound(soundUri)
            : null,
        actions: const <AndroidNotificationAction>[
          AndroidNotificationAction('take', 'Take'),
          AndroidNotificationAction('snooze_15', 'Snooze 15m'),
          AndroidNotificationAction('skip', 'Skip'),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'medication_reminder',
      ),
    );
  }
}
