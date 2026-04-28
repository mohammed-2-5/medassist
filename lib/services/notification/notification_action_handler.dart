import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/repositories/medication_repository.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// Handles notification action button taps (Take/Snooze/Skip).
///
/// Runs in the background — creates its own [AppDatabase] instance and
/// delegates dose operations to [MedicationRepository] for transactional
/// safety. Uses a single shared database instance to avoid connection leaks.
class NotificationActionHandler {
  factory NotificationActionHandler() => _instance;
  NotificationActionHandler._internal();
  static final NotificationActionHandler _instance =
      NotificationActionHandler._internal();

  final NotificationService _notificationService = NotificationService();

  /// Shared database instance — avoids creating a new connection per action.
  late final AppDatabase _database = AppDatabase();
  late final MedicationRepository _repository = MedicationRepository(_database);

  @pragma('vm:entry-point')
  static Future<void> handleAction(NotificationResponse response) async {
    // Ensure Flutter bindings are initialised — this callback may run in a
    // background isolate where the plugin channel is not yet available.
    WidgetsFlutterBinding.ensureInitialized();
    final instance = NotificationActionHandler();
    await instance._processAction(response);
  }

  /// Validate + coerce notification payload. Returns null if invalid.
  Map<String, dynamic>? _parsePayload(String payload) {
    try {
      final decoded = json.decode(payload);
      if (decoded is! Map<String, dynamic>) return null;

      final medicationId = decoded['medicationId'];
      final medicationName = decoded['medicationName'];
      final dose = decoded['dose'];

      if (medicationId is! int || medicationId <= 0) return null;
      if (medicationName is! String || medicationName.trim().isEmpty) {
        return null;
      }
      if (medicationName.length > 200) return null;

      final safeDose = dose is String && dose.length <= 100 ? dose : '';

      final scheduledHour = decoded['scheduledHour'];
      final scheduledMinute = decoded['scheduledMinute'];
      final safeHour =
          scheduledHour is int && scheduledHour >= 0 && scheduledHour < 24
          ? scheduledHour
          : null;
      final safeMinute =
          scheduledMinute is int && scheduledMinute >= 0 && scheduledMinute < 60
          ? scheduledMinute
          : null;

      return {
        'medicationId': medicationId,
        'medicationName': medicationName,
        'dose': safeDose,
        'scheduledHour': safeHour,
        'scheduledMinute': safeMinute,
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> _processAction(NotificationResponse response) async {
    try {
      final actionId = response.actionId;
      final payload = response.payload;

      if (payload == null || actionId == null) {
        debugPrint('No payload or action ID found');
        await _showErrorNotification('Could not process medication action');
        return;
      }

      final data = _parsePayload(payload);
      if (data == null) {
        debugPrint('Invalid notification payload schema');
        await _showErrorNotification('Could not process medication action');
        return;
      }
      final medicationId = data['medicationId'] as int;
      final medicationName = data['medicationName'] as String;
      final dose = data['dose'] as String;
      final now = DateTime.now();
      final scheduledHour = (data['scheduledHour'] as int?) ?? now.hour;
      final scheduledMinute = (data['scheduledMinute'] as int?) ?? now.minute;

      debugPrint(
        'Processing action: $actionId for medication: $medicationName',
      );

      switch (actionId) {
        case 'take':
          await _handleTakeAction(
            medicationId,
            medicationName,
            dose,
            scheduledHour,
            scheduledMinute,
          );
        case 'snooze_15':
          await _handleSnoozeAction(
            medicationId,
            medicationName,
            dose,
            15,
            scheduledHour,
            scheduledMinute,
          );
        case 'snooze_30':
          await _handleSnoozeAction(
            medicationId,
            medicationName,
            dose,
            30,
            scheduledHour,
            scheduledMinute,
          );
        case 'skip':
          await _handleSkipAction(
            medicationId,
            medicationName,
            scheduledHour,
            scheduledMinute,
          );
        default:
          debugPrint('Unknown action: $actionId');
      }
    } catch (e, stack) {
      debugPrint('Error processing notification action: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  /// Handle "Take" action — delegates to repository for transactional safety.
  Future<void> _handleTakeAction(
    int medicationId,
    String medicationName,
    String dose,
    int scheduledHour,
    int scheduledMinute,
  ) async {
    try {
      final now = DateTime.now();

      final result = await _repository.takeDose(
        medicationId: medicationId,
        scheduledDate: now,
        scheduledHour: scheduledHour,
        scheduledMinute: scheduledMinute,
      );

      await _notificationService.cancelAllRecurringRemindersForMedication(
        medicationId,
      );

      debugPrint('Dose take result: ${result.runtimeType} for $medicationId');

      await _showSuccessNotification(
        'Dose Taken',
        '$medicationName ($dose) marked as taken',
      );
    } catch (e) {
      debugPrint('Error handling take action: $e');
      await _showErrorNotification('Failed to record dose');
    }
  }

  /// Handle "Snooze" action with smart snooze limits.
  Future<void> _handleSnoozeAction(
    int medicationId,
    String medicationName,
    String dose,
    int minutes,
    int scheduledHour,
    int scheduledMinute,
  ) async {
    try {
      final now = DateTime.now();

      await _database.resetOldSnoozeHistory();

      final medication = await _database.getMedicationById(medicationId);
      if (medication == null) {
        await _showErrorNotification('Medication not found');
        return;
      }

      // Enforce snooze limits
      final snoozeHistory = await _database.getTodaySnoozeHistory(medicationId);
      final currentSnoozeCount = snoozeHistory?.snoozeCount ?? 0;
      final maxSnoozes = medication.maxSnoozesPerDay;

      if (currentSnoozeCount >= maxSnoozes) {
        debugPrint(
          'Snooze limit reached for $medicationId ($currentSnoozeCount/$maxSnoozes)',
        );
        await _showErrorNotification(
          'Snooze limit reached ($maxSnoozes/$maxSnoozes). Please take your medication now.',
        );
        return;
      }

      await _database.incrementSnoozeCount(
        medicationId: medicationId,
        suggestedMinutes: minutes,
      );

      final snoozeUntil = now.add(Duration(minutes: minutes));

      await _repository.snoozeDose(
        medicationId: medicationId,
        scheduledDate: now,
        scheduledHour: scheduledHour,
        scheduledMinute: scheduledMinute,
        notes:
            'Snoozed for $minutes minutes until ${snoozeUntil.hour}:${snoozeUntil.minute.toString().padLeft(2, '0')} (${currentSnoozeCount + 1}/$maxSnoozes)',
      );

      await _notificationService.snoozeNotification(
        medicationId: medicationId,
        medicationName: medicationName,
        dose: dose,
        minutes: minutes,
        scheduledHour: scheduledHour,
        scheduledMinute: scheduledMinute,
      );

      await _showSuccessNotification(
        'Snoozed for $minutes min',
        'Reminder for $medicationName at ${snoozeUntil.hour}:${snoozeUntil.minute.toString().padLeft(2, '0')} (${currentSnoozeCount + 1}/$maxSnoozes snoozes today)',
      );
    } catch (e) {
      debugPrint('Error handling snooze action: $e');
      await _showErrorNotification('Failed to snooze reminder');
    }
  }

  /// Handle "Skip" action.
  Future<void> _handleSkipAction(
    int medicationId,
    String medicationName,
    int scheduledHour,
    int scheduledMinute,
  ) async {
    try {
      final now = DateTime.now();

      await _repository.skipDose(
        medicationId: medicationId,
        scheduledDate: now,
        scheduledHour: scheduledHour,
        scheduledMinute: scheduledMinute,
      );

      await _notificationService.cancelAllRecurringRemindersForMedication(
        medicationId,
      );

      await _showSuccessNotification(
        'Dose Skipped',
        '$medicationName marked as skipped',
      );
    } catch (e) {
      debugPrint('Error handling skip action: $e');
      await _showErrorNotification('Failed to skip dose');
    }
  }

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

    await _notificationService.plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      message,
      notificationDetails,
    );
  }

  Future<void> _showErrorNotification(String message) async {
    await _showSuccessNotification('Error', message);
  }
}
