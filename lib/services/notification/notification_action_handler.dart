import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// Handles notification action button taps (Take/Snooze/Skip)
/// Processes actions in background and updates database
class NotificationActionHandler {
  factory NotificationActionHandler() => _instance;
  NotificationActionHandler._internal();
  static final NotificationActionHandler _instance =
      NotificationActionHandler._internal();

  final NotificationService _notificationService = NotificationService();

  /// Process notification action
  @pragma('vm:entry-point')
  static Future<void> handleAction(NotificationResponse response) async {
    final instance = NotificationActionHandler();
    await instance._processAction(response);
  }

  /// Process the notification action
  Future<void> _processAction(NotificationResponse response) async {
    try {
      final actionId = response.actionId;
      final payload = response.payload;

      if (payload == null || actionId == null) {
        debugPrint('No payload or action ID found');
        return;
      }

      final data = json.decode(payload) as Map<String, dynamic>;
      final medicationId = data['medicationId'] as int;
      final medicationName = data['medicationName'] as String;
      final dose = data['dose'] as String;

      debugPrint('Processing action: $actionId for medication: $medicationName');

      switch (actionId) {
        case 'take':
          await _handleTakeAction(medicationId, medicationName, dose);
        case 'snooze_15':
          await _handleSnoozeAction(medicationId, medicationName, dose, 15);
        case 'snooze_30':
          await _handleSnoozeAction(medicationId, medicationName, dose, 30);
        case 'skip':
          await _handleSkipAction(medicationId, medicationName);
        default:
          debugPrint('Unknown action: $actionId');
      }
    } catch (e, stack) {
      debugPrint('Error processing notification action: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  /// Handle "Take" action
  Future<void> _handleTakeAction(
    int medicationId,
    String medicationName,
    String dose,
  ) async {
    try {
      final database = AppDatabase();
      final now = DateTime.now();

      // Record dose as taken
      await database.recordDoseTaken(
        medicationId: medicationId,
        scheduledDate: now,
        scheduledHour: now.hour,
        scheduledMinute: now.minute,
        actualTime: now,
      );

      // Update stock
      final medication = await database.getMedicationById(medicationId);
      if (medication != null) {
        final newStock = (medication.stockQuantity - medication.dosePerTime).round();
        await database.updateMedicationStock(
          medicationId,
          newStock >= 0 ? newStock : 0,
        );
      }

      // Cancel all recurring reminders for this medication
      await _notificationService.cancelAllRecurringRemindersForMedication(medicationId);

      // Show success notification
      await _showSuccessNotification(
        'Dose Taken',
        '$medicationName ($dose) marked as taken',
      );

      debugPrint('Dose taken for medication $medicationId');
    } catch (e) {
      debugPrint('Error handling take action: $e');
      await _showErrorNotification('Failed to record dose');
    }
  }

  /// Handle "Snooze" action with smart snooze limits
  Future<void> _handleSnoozeAction(
    int medicationId,
    String medicationName,
    String dose,
    int minutes,
  ) async {
    try {
      final database = AppDatabase();
      final now = DateTime.now();

      // Reset old snooze history (removes records from previous days)
      await database.resetOldSnoozeHistory();

      // Get medication to check max snoozes
      final medication = await database.getMedicationById(medicationId);
      if (medication == null) {
        debugPrint('Medication not found');
        await _showErrorNotification('Medication not found');
        return;
      }

      // Check snooze count for today
      final snoozeHistory = await database.getTodaySnoozeHistory(medicationId);
      final currentSnoozeCount = snoozeHistory?.snoozeCount ?? 0;
      final maxSnoozes = medication.maxSnoozesPerDay;

      // Check if limit reached
      if (currentSnoozeCount >= maxSnoozes) {
        debugPrint('Snooze limit reached for medication $medicationId ($currentSnoozeCount/$maxSnoozes)');
        await _showErrorNotification(
          'Snooze limit reached ($maxSnoozes/$maxSnoozes). Please take your medication now.',
        );
        return;
      }

      // Increment snooze count
      await database.incrementSnoozeCount(
        medicationId: medicationId,
        suggestedMinutes: minutes,
      );

      final snoozeUntil = now.add(Duration(minutes: minutes));

      // Record dose as snoozed
      await database.recordDoseSnoozed(
        medicationId: medicationId,
        scheduledDate: now,
        scheduledHour: now.hour,
        scheduledMinute: now.minute,
        notes: 'Snoozed for $minutes minutes until ${snoozeUntil.hour}:${snoozeUntil.minute.toString().padLeft(2, '0')} (${currentSnoozeCount + 1}/$maxSnoozes)',
      );

      // Schedule snooze notification
      await _notificationService.snoozeNotification(
        medicationId: medicationId,
        medicationName: medicationName,
        dose: dose,
        minutes: minutes,
      );

      // Show confirmation with snooze count
      await _showSuccessNotification(
        'Snoozed for $minutes min',
        'Reminder for $medicationName at ${snoozeUntil.hour}:${snoozeUntil.minute.toString().padLeft(2, '0')} (${currentSnoozeCount + 1}/$maxSnoozes snoozes today)',
      );

      debugPrint('Dose snoozed for medication $medicationId for $minutes minutes (${currentSnoozeCount + 1}/$maxSnoozes)');
    } catch (e) {
      debugPrint('Error handling snooze action: $e');
      await _showErrorNotification('Failed to snooze reminder');
    }
  }

  /// Handle "Skip" action
  Future<void> _handleSkipAction(
    int medicationId,
    String medicationName,
  ) async {
    try {
      final database = AppDatabase();
      final now = DateTime.now();

      // Record dose as skipped
      await database.recordDoseSkipped(
        medicationId: medicationId,
        scheduledDate: now,
        scheduledHour: now.hour,
        scheduledMinute: now.minute,
      );

      // Cancel all recurring reminders for this medication
      await _notificationService.cancelAllRecurringRemindersForMedication(medicationId);

      // Show confirmation
      await _showSuccessNotification(
        'Dose Skipped',
        '$medicationName marked as skipped',
      );

      debugPrint('Dose skipped for medication $medicationId');
    } catch (e) {
      debugPrint('Error handling skip action: $e');
      await _showErrorNotification('Failed to skip dose');
    }
  }

  /// Show success notification
  Future<void> _showSuccessNotification(String title, String message) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notification = FlutterLocalNotificationsPlugin();
    await notification.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      message,
      notificationDetails,
    );
  }

  /// Show error notification
  Future<void> _showErrorNotification(String message) async {
    await _showSuccessNotification('Error', message);
  }
}
