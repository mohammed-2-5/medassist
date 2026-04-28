import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/repositories/medication_repository.dart';
import 'package:med_assist/services/notification/notification_channels.dart';
import 'package:med_assist/services/notification/notification_id_generator.dart';
import 'package:timezone/timezone.dart' as tz;

/// Schedules low-stock and expiry-date notifications.
class NotificationStockExpiry {
  NotificationStockExpiry._();

  /// Schedule low stock notification using the medication's configured threshold.
  static Future<void> scheduleLowStock(
    FlutterLocalNotificationsPlugin notifications,
    Medication medication,
  ) async {
    final dailyUsage = MedicationRepository.effectiveDailyUsage(medication);
    if (dailyUsage <= 0) return;

    final daysRemaining = (medication.stockQuantity / dailyUsage).floor();
    final threshold = medication.reminderDaysBeforeRunOut;

    if (daysRemaining > threshold || daysRemaining <= 0) return;

    final lowStockId = NotificationIdGenerator.lowStock(medication.id);
    await notifications.cancel(lowStockId);

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tzNotificationTime = tz.TZDateTime.from(
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9),
      tz.local,
    );

    final payload = json.encode({
      'type': 'low_stock',
      'medicationId': medication.id,
      'medicationName': medication.medicineName,
      'daysRemaining': daysRemaining,
    });

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationChannels.stockChannelId,
        'Stock Alerts',
        channelDescription: 'Notifications for low medication stock',
        icon: 'ic_notification',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await notifications.zonedSchedule(
      lowStockId,
      'Low Stock: ${medication.medicineName}',
      'Only $daysRemaining day${daysRemaining != 1 ? 's' : ''} of stock remaining. Time to refill!',
      tzNotificationTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint(
      'Scheduled low stock notification for ${medication.medicineName} ($daysRemaining days left, threshold: $threshold)',
    );
  }

  /// Schedule expiry date notification for a medication.
  static Future<void> scheduleExpiry(
    FlutterLocalNotificationsPlugin notifications,
    Medication medication,
  ) async {
    final expiryDate = medication.expiryDate;
    if (expiryDate == null) return;

    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    final threshold = medication.reminderDaysBeforeExpiry;

    if (daysUntilExpiry > threshold || daysUntilExpiry < 0) return;

    final expiryId = NotificationIdGenerator.expiry(medication.id);
    await notifications.cancel(expiryId);

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tzNotificationTime = tz.TZDateTime.from(
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10),
      tz.local,
    );

    final payload = json.encode({
      'type': 'expiry_warning',
      'medicationId': medication.id,
      'medicationName': medication.medicineName,
      'daysUntilExpiry': daysUntilExpiry,
    });

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationChannels.stockChannelId,
        'Stock Alerts',
        channelDescription: 'Notifications for medication expiry',
        icon: 'ic_notification',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final title = daysUntilExpiry == 0
        ? 'Expired: ${medication.medicineName}'
        : 'Expiring Soon: ${medication.medicineName}';
    final body = daysUntilExpiry == 0
        ? '${medication.medicineName} has expired today. Please replace it.'
        : '${medication.medicineName} expires in $daysUntilExpiry day${daysUntilExpiry != 1 ? 's' : ''}. Consider getting a replacement.';

    await notifications.zonedSchedule(
      expiryId,
      title,
      body,
      tzNotificationTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint(
      'Scheduled expiry notification for ${medication.medicineName} ($daysUntilExpiry days until expiry)',
    );
  }

  /// Cancel expiry notification for a medication.
  static Future<void> cancelExpiry(
    FlutterLocalNotificationsPlugin notifications,
    int medicationId,
  ) async {
    await notifications.cancel(NotificationIdGenerator.expiry(medicationId));
  }
}
