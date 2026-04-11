import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/services/notification/notification_action_handler.dart';
import 'package:med_assist/services/notification/notification_channels.dart';
import 'package:med_assist/services/notification/notification_diagnostics.dart';
import 'package:med_assist/services/notification/notification_permissions.dart';
import 'package:med_assist/services/notification/notification_recurring.dart';
import 'package:med_assist/services/notification/notification_scheduler.dart';
import 'package:med_assist/services/notification/notification_stock_expiry.dart';
import 'package:med_assist/services/notification/notification_timezone.dart';

/// Facade for the notification subsystem.
///
/// All heavy logic lives in dedicated helpers:
/// [NotificationTimezone], [NotificationChannels], [NotificationPermissions],
/// [NotificationScheduler], [NotificationStockExpiry], [NotificationRecurring],
/// [NotificationDiagnostics].
@pragma('vm:entry-point')
class NotificationService {
  @pragma('vm:entry-point')
  factory NotificationService() => _instance;

  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  bool _ready = false;
  late FlutterLocalNotificationsPlugin _notifications;

  /// Callback for notification taps.
  Function(String?)? onNotificationTap;

  FlutterLocalNotificationsPlugin get plugin => _notifications;

  // ── Initialization ──────────────────────────────────────────────────

  @pragma('vm:entry-point')
  Future<void> initialize() async {
    if (_ready) return;
    _notifications = FlutterLocalNotificationsPlugin();

    await NotificationTimezone.initialize();

    const androidSettings = AndroidInitializationSettings('ic_notification');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onNotificationResponse,
    );

    await NotificationChannels.createAll(_notifications);
    _ready = true;
    debugPrint('NotificationService initialized');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationResponse(
      NotificationResponse response) async {
    final actionId = response.actionId;
    if (actionId != null && actionId.isNotEmpty) {
      await NotificationActionHandler.handleAction(response);
      return;
    }
    NotificationService().onNotificationTap?.call(response.payload);
  }

  // ── Permissions ─────────────────────────────────────────────────────

  Future<bool> requestPermissions() =>
      NotificationPermissions.requestPermissions(_notifications);

  Future<bool> requestExactAlarmsPermission() =>
      NotificationPermissions.requestExactAlarms(_notifications);

  Future<bool> areNotificationsEnabled() =>
      NotificationPermissions.areNotificationsEnabled(_notifications);

  Future<bool> canScheduleExactAlarms() =>
      NotificationPermissions.canScheduleExactAlarms(_notifications);

  Future<bool> isBatteryOptimizationDisabled() =>
      NotificationPermissions.isBatteryOptimizationDisabled();

  // ── Scheduling ──────────────────────────────────────────────────────

  @pragma('vm:entry-point')
  Future<void> scheduleRemindersForMedication(
    Medication medication,
    List<ReminderTime> reminderTimes,
  ) async {
    await initialize();
    await NotificationScheduler.scheduleForMedication(
        _notifications, medication, reminderTimes);
  }

  @pragma('vm:entry-point')
  Future<void> snoozeNotification({
    required int medicationId,
    required String medicationName,
    required String dose,
    required int minutes,
    String? customSoundPath,
  }) async {
    await initialize();
    await NotificationScheduler.snooze(
      _notifications,
      medicationId: medicationId,
      medicationName: medicationName,
      dose: dose,
      minutes: minutes,
    );
  }

  @pragma('vm:entry-point')
  Future<void> cancelMedicationReminders(int medicationId) async {
    await NotificationScheduler.cancelForMedication(
        _notifications, medicationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  // ── Stock & Expiry ──────────────────────────────────────────────────

  Future<void> scheduleLowStockNotification(Medication medication) async {
    await initialize();
    await NotificationStockExpiry.scheduleLowStock(_notifications, medication);
  }

  Future<void> scheduleExpiryNotification(Medication medication) async {
    await initialize();
    await NotificationStockExpiry.scheduleExpiry(_notifications, medication);
  }

  Future<void> cancelExpiryNotification(int medicationId) async {
    await NotificationStockExpiry.cancelExpiry(_notifications, medicationId);
  }

  // ── Recurring Reminders ─────────────────────────────────────────────

  Future<void> scheduleRecurringReminders({
    required int medicationId,
    required int reminderIndex,
    required String medicationName,
    required String dose,
    required int intervalMinutes,
    int maxReminders = 4,
    String? customSoundPath,
  }) async {
    await initialize();
    await NotificationRecurring.schedule(
      _notifications,
      medicationId: medicationId,
      reminderIndex: reminderIndex,
      medicationName: medicationName,
      dose: dose,
      intervalMinutes: intervalMinutes,
      maxReminders: maxReminders,
    );
  }

  Future<void> cancelRecurringReminders(
      int medicationId, int reminderIndex) async {
    await NotificationRecurring.cancelForReminderTime(
        _notifications, medicationId, reminderIndex);
  }

  Future<void> cancelAllRecurringRemindersForMedication(
      int medicationId) async {
    await NotificationRecurring.cancelForMedication(
        _notifications, medicationId);
  }

  // ── Diagnostics & Settings ──────────────────────────────────────────

  Future<List<PendingNotificationRequest>> getPendingNotifications() =>
      _notifications.pendingNotificationRequests();

  Future<void> showTestNotification() =>
      NotificationDiagnostics.showTestNotification(_notifications);

  Future<void> scheduleTestNotificationIn1Minute() async {
    await initialize();
    await NotificationDiagnostics.scheduleTestIn1Minute(_notifications);
  }

  Future<Map<String, dynamic>> getDiagnostics() =>
      NotificationDiagnostics.getDiagnostics(_notifications);

  Future<void> openExactAlarmSettings() =>
      NotificationDiagnostics.openExactAlarmSettings();

  Future<void> openChannelSettings(
          {String channelId = NotificationChannels.medicationChannelId}) =>
      NotificationDiagnostics.openChannelSettings(channelId: channelId);

  Future<void> openMedicationReminderSoundSettings() =>
      NotificationDiagnostics.openMedicationReminderSoundSettings();

  Future<void> requestBatteryOptimizationExemption() =>
      NotificationDiagnostics.requestBatteryOptimizationExemption();

  Future<void> openAppNotificationSettings() =>
      NotificationDiagnostics.openAppNotificationSettings();

  // ── Timezone ────────────────────────────────────────────────────────

  Future<bool> setTimezone(String timezoneName) async =>
      NotificationTimezone.setTimezone(timezoneName);

  List<String> getCommonTimezones() => NotificationTimezone.commonTimezones;
}
