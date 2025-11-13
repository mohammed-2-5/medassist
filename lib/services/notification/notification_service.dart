import 'dart:convert';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart'; // 👈 add this
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/services/notification/notification_action_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
/// Comprehensive Notification Service for medication reminders
///
/// Features:
/// - Schedule daily medication reminders
/// - Snooze functionality (15/30/60 minutes)
/// - Low stock notifications
/// - Missed dose tracking
/// - Handle notification taps with navigation
/// - Cancel notifications on medication delete/pause
@pragma('vm:entry-point')
class NotificationService {

  @pragma('vm:entry-point')
  factory NotificationService() => _instance;

  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  bool _ready = false; // 👈 guard so we init once
  late FlutterLocalNotificationsPlugin _notifications ;

  /// Callback for notification taps
  Function(String?)? onNotificationTap;

  /// Initialize notification service
  @pragma('vm:entry-point')
  Future<void> initialize() async {
    _notifications =
        FlutterLocalNotificationsPlugin();
    // Initialize timezone database
    if (_ready) return; // ✅ guard once
    tz.initializeTimeZones();
    // 2) Resolve device timezone and set tz.local
    try {
      // Get timezone from device
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final timezoneName = timezoneInfo.toString();
      debugPrint('📍 Device timezone detected: $timezoneName');

      // Try to set the timezone from device
      try {
        final location = tz.getLocation(timezoneName);
        tz.setLocalLocation(location);
        debugPrint('✅ Timezone set successfully to: ${tz.local.name}');
        debugPrint('✅ Current offset: ${tz.local.currentTimeZone.offset}');
      } catch (locationError) {
        debugPrint('⚠️ Timezone "$timezoneName" not found in database');
        debugPrint('⚠️ Error: $locationError');

        // Try to find a matching timezone by checking variations
        final variations = _getTimezoneVariations(timezoneName);
        var timezoneSet = false;

        for (final variation in variations) {
          try {
            final location = tz.getLocation(variation);
            tz.setLocalLocation(location);
            debugPrint('✅ Using timezone variation: $variation');
            timezoneSet = true;
            break;
          } catch (e) {
            continue;
          }
        }

        if (!timezoneSet) {
          throw Exception('Could not find matching timezone for: $timezoneName');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in timezone detection: $e');
      debugPrint('Stack trace: $stackTrace');

      // Get device time offset to make a better guess
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      debugPrint('📍 Device timezone offset: ${offset.inHours} hours');

      // Try to find timezone based on offset
      final timezoneByOffset = _getTimezoneByOffset(offset);
      var timezoneSet = false;

      for (final timezoneName in timezoneByOffset) {
        try {
          tz.setLocalLocation(tz.getLocation(timezoneName));
          debugPrint('✅ Using timezone based on offset: $timezoneName');
          timezoneSet = true;
          break;
        } catch (e) {
          continue;
        }
      }

      if (!timezoneSet) {
        debugPrint('⚠️ All timezone detection failed, using UTC');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }

    // Complete the initialization
    await _completeInitialization();
  }

  /// Get timezone variations for common formatting differences
  List<String> _getTimezoneVariations(String timezoneName) {
    final variations = <String>[timezoneName];

    // Handle common variations
    if (timezoneName.contains('_')) {
      variations.add(timezoneName.replaceAll('_', ' '));
    }
    if (timezoneName.contains(' ')) {
      variations.add(timezoneName.replaceAll(' ', '_'));
    }

    // Handle case variations
    variations.add(timezoneName.toLowerCase());
    variations.add(timezoneName.toUpperCase());

    return variations;
  }

  /// Get likely timezones based on UTC offset
  List<String> _getTimezoneByOffset(Duration offset) {
    final offsetHours = offset.inHours;

    // Map of UTC offsets to timezones (ordered by population/likelihood)
    final timezoneMap = <int, List<String>>{
      -12: ['Pacific/Auckland'],
      -11: ['Pacific/Samoa'],
      -10: ['Pacific/Honolulu'],
      -9: ['America/Anchorage'],
      -8: ['America/Los_Angeles', 'America/Vancouver'],
      -7: ['America/Denver', 'America/Phoenix'],
      -6: ['America/Chicago', 'America/Mexico_City'],
      -5: ['America/New_York', 'America/Toronto'],
      -4: ['America/Caracas', 'America/Halifax'],
      -3: ['America/Sao_Paulo', 'America/Argentina/Buenos_Aires'],
      -2: ['Atlantic/South_Georgia'],
      -1: ['Atlantic/Azores'],
      0: ['UTC', 'Europe/London', 'Africa/Casablanca'],
      1: ['Europe/Paris', 'Europe/Berlin', 'Africa/Lagos'],
      2: ['Africa/Cairo', 'Europe/Athens', 'Africa/Johannesburg'], // Egypt is +2
      3: ['Europe/Moscow', 'Asia/Riyadh', 'Africa/Nairobi'],
      4: ['Asia/Dubai', 'Asia/Baku'],
      5: ['Asia/Karachi', 'Asia/Tashkent'],
      6: ['Asia/Dhaka', 'Asia/Almaty'],
      7: ['Asia/Bangkok', 'Asia/Jakarta'],
      8: ['Asia/Shanghai', 'Asia/Singapore', 'Asia/Hong_Kong'],
      9: ['Asia/Tokyo', 'Asia/Seoul'],
      10: ['Australia/Sydney', 'Australia/Melbourne'],
      11: ['Pacific/Noumea'],
      12: ['Pacific/Fiji', 'Pacific/Auckland'],
    };

    return timezoneMap[offsetHours] ?? ['UTC'];
  }

  Future<void> _completeInitialization() async {
    // Android configuration
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS configuration
    const iosSettings = DarwinInitializationSettings(
      
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onNotificationResponse,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
    _ready = true; // ✅ set the field
    debugPrint('NotificationService initialized');

  }
  FlutterLocalNotificationsPlugin get plugin => _notifications;
  /// Handle notification tap and action buttons
  @pragma('vm:entry-point')
  static void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    final actionId = response.actionId;

    debugPrint('Notification response - Action: $actionId, Payload: $payload');

    // If action button was tapped, handle it
    if (actionId != null) {
      NotificationActionHandler.handleAction(response);
      return;
    }

    // Otherwise, call the tap callback if set
    final instance = NotificationService();
    instance.onNotificationTap?.call(payload);
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    // Medication reminders channel - MAX importance for Samsung devices
    const medicationChannel = AndroidNotificationChannel(
      'medication_reminders_v2', // 👈 new id
      'Medication Reminders',
      description: 'Notifications for scheduled medication doses',
      importance: Importance.max, // Changed from high to max for Samsung

      enableLights: true,
      ledColor: Color(0xFF2196F3), // Blue LED for Samsung devices
    );

    // Stock alerts channel
    const stockChannel = AndroidNotificationChannel(
      'stock_alerts',
      'Stock Alerts',
      description: 'Notifications for low medication stock',
    );

    // General notifications channel
    const generalChannel = AndroidNotificationChannel(
      'general',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.low,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(medicationChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(stockChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);

    debugPrint('Notification channels created');
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Request notification permission first (Android 13+)
      final notificationGranted = await androidImplementation
          ?.requestNotificationsPermission();

      debugPrint('📱 Notification permission: $notificationGranted');

      // Request exact alarm permission (Android 12+)
      // This will open settings if permission is needed
      final exactAlarmGranted = await androidImplementation
          ?.requestExactAlarmsPermission();

      debugPrint('📱 Exact alarms permission: $exactAlarmGranted');

      // If exact alarm permission is false, guide user to settings
      if (exactAlarmGranted == false) {
        debugPrint('⚠️ Exact alarms permission denied or needs to be granted in settings');
        // The permission dialog should have opened automatically
      }

      return (exactAlarmGranted ?? true) && (notificationGranted ?? true);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('iOS notification permission: $granted');
      return granted ?? false;
    }

    return false;
  }

  /// Request exact alarms permission specifically
  /// Opens the system settings where user can enable it
  Future<bool> requestExactAlarmsPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      debugPrint('📱 Requesting exact alarms permission...');
      final granted = await androidImplementation?.requestExactAlarmsPermission();
      debugPrint('📱 Exact alarms permission result: $granted');

      return granted ?? false;
    }
    return true;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS doesn't provide a way to check permission status
      return true;
    }
    return false;
  }

  /// Check if exact alarms can be scheduled (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // This method checks if the app can schedule exact alarms
      final canSchedule = await androidImplementation?.canScheduleExactNotifications() ?? false;
      debugPrint('📱 Can schedule exact alarms: $canSchedule');
      return canSchedule;
    }
    return true;
  }

  /// Schedule all reminders for a medication
  @pragma('vm:entry-point')
  Future<void> scheduleRemindersForMedication(
    Medication medication,
    List<ReminderTime> reminderTimes,
  ) async {
    await initialize(); // 👈 ensure tz.local is set and plugin ready
    if (!medication.isActive) {
      debugPrint('Medication ${medication.id} is not active, skipping reminders');
      return;
    }

    // Cancel existing reminders first
    await cancelMedicationReminders(medication.id);

    for (var i = 0; i < reminderTimes.length; i++) {
      final reminderTime = reminderTimes[i];
      final notificationId = _generateNotificationId(medication.id, i);

      await _scheduleDailyReminder(
        id: notificationId,
        medicationId: medication.id,
        medicationName: medication.medicineName,
        dose: '${medication.dosePerTime} ${medication.doseUnit}',
        hour: reminderTime.hour,
        minute: reminderTime.minute,
        customSoundPath: medication.customSoundPath,
      );
    }

// ✅ Debug: print pending notifications
    final pending = await _notifications.pendingNotificationRequests();
    debugPrint('Pending after scheduling dose reminder: ${pending.length}');
    for (final p in pending) {
      debugPrint(' -> id=${p.id} title=${p.title} body=${p.body} payload=${p.payload}');
    debugPrint('Scheduled ${reminderTimes.length} reminders for ${medication.medicineName}');
  }}

  /// Schedule a daily reminder at specific time
  Future<void> _scheduleDailyReminder({
    required int id,
    required int medicationId,
    required String medicationName,
    required String dose,
    required int hour,
    required int minute,
    String? customSoundPath,
  }) async {
    await initialize(); // 👈

    final now = DateTime.now();
    debugPrint('⏰ Current time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    debugPrint('⏰ Scheduling for: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    debugPrint('⏰ Current timezone: ${tz.local.name}');
    if (customSoundPath != null) {
      debugPrint('🔊 Using custom sound: $customSoundPath');
    }

    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      debugPrint('⏰ Time has passed, scheduling for tomorrow');
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Calculate when this will actually fire
    final nowTz = tz.TZDateTime.now(tz.local);
    final diff = tzScheduledDate.difference(nowTz);
    final hoursUntil = diff.inHours;
    final minutesUntil = diff.inMinutes % 60;

    debugPrint('⏰ TZ scheduled date: $tzScheduledDate');
    debugPrint('⏰ Current TZ time: $nowTz');
    debugPrint('⏰ Will fire in: ${hoursUntil}h ${minutesUntil}m');
    debugPrint('⏰ Scheduled for: ${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')} at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');

    // Create payload with medication info
    final payload = json.encode({
      'type': 'medication_reminder',
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dose': dose,
    });

    // Note: customSoundPath is reserved for future custom sound support
    // Currently all sounds use system default (null path)
    const androidDetails = AndroidNotificationDetails(
      'medication_reminders_v2',
      'Medication Reminders',
      channelDescription: 'Notifications for scheduled medication doses',
      importance: Importance.max, // MAX for Samsung devices
      priority: Priority.max, // MAX priority
      // sound: null means use system default notification sound
      enableLights: true,
      color: Color(0xFF2196F3),
      ledColor: Color(0xFF2196F3),
      ledOnMs: 1000,
      ledOffMs: 500,
      fullScreenIntent: true, // Show as heads-up on Samsung
      category: AndroidNotificationCategory.alarm, // Treat as alarm
      visibility: NotificationVisibility.public, // Show on lock screen
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'take',
          'Take',
        ),
        AndroidNotificationAction(
          'snooze_15',
          'Snooze 15m',
        ),
        AndroidNotificationAction(
          'skip',
          'Skip',
        ),
      ],
    );

    // iOS notification details - uses system default sound
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // sound: null uses system default notification sound
      categoryIdentifier: 'medication_reminder',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      'Time to take $medicationName',
      'Take $dose now',
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    debugPrint('✅ Scheduled reminder for $medicationName');
    debugPrint('   → Notification ID: $id');
    debugPrint('   → Will fire at: ${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    debugPrint('   → Repeats: Daily at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    debugPrint('   → Time until first notification: ${hoursUntil}h ${minutesUntil}m');
  }

  /// Snooze a notification by specified minutes
  @pragma('vm:entry-point')
  Future<void> snoozeNotification({
    required int medicationId,
    required String medicationName,
    required String dose,
    required int minutes,
    String? customSoundPath,
  }) async {
    await initialize(); // 👈
    final snoozeId = _generateSnoozeId(medicationId);

    // Cancel any existing snooze
    await _notifications.cancel(snoozeId);

    final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
    final tzSnoozeTime = tz.TZDateTime.from(DateTime.now().add(Duration(minutes: minutes)), tz.local);

    final payload = json.encode({
      'type': 'snoozed_reminder',
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dose': dose,
    });

    // Note: customSoundPath reserved for future use
    // Currently uses system default sound
    const androidDetails = AndroidNotificationDetails(
      'medication_reminders_v2',
      'Medication Reminders',
      channelDescription: 'Notifications for scheduled medication doses',
      importance: Importance.high,
      priority: Priority.high,
      // sound: null uses system default
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // sound: null uses system default
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      snoozeId,
      'Reminder: Take $medicationName',
      'Take $dose now (Snoozed)',
      tzSnoozeTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint('Snoozed reminder for $medicationName for $minutes minutes');
  }

  /// Schedule low stock notification
  Future<void> scheduleLowStockNotification(Medication medication) async {
    await initialize(); // 👈
    final dailyUsage = medication.dosePerTime * medication.timesPerDay;
    final daysRemaining = medication.stockQuantity > 0
        ? (medication.stockQuantity / dailyUsage).floor()
        : 0;

    // Only schedule if stock is low (≤3 days)
    if (daysRemaining > 3 || daysRemaining <= 0) {
      return;
    }

    final lowStockId = _generateLowStockId(medication.id);

    // Schedule notification for tomorrow at 9 AM
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final notificationTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
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

    const androidDetails = AndroidNotificationDetails(
      'stock_alerts',
      'Stock Alerts',
      channelDescription: 'Notifications for low medication stock',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      lowStockId,
      'Low Stock: ${medication.medicineName}',
      'Only $daysRemaining day${daysRemaining != 1 ? 's' : ''} of stock remaining. Time to refill!',
      tzNotificationTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint('Scheduled low stock notification for ${medication.medicineName}');
  }

  /// Cancel all reminders for a medication
  @pragma('vm:entry-point')
  Future<void> cancelMedicationReminders(int medicationId) async {
    // Cancel up to 6 possible reminder times (max times per day)
    for (var i = 0; i < 6; i++) {
      final notificationId = _generateNotificationId(medicationId, i);
      await _notifications.cancel(notificationId);
    }

    // Cancel low stock notification
    final lowStockId = _generateLowStockId(medicationId);
    await _notifications.cancel(lowStockId);

    // Cancel any snooze
    final snoozeId = _generateSnoozeId(medicationId);
    await _notifications.cancel(snoozeId);

    // Cancel all recurring reminders
    await cancelAllRecurringRemindersForMedication(medicationId);

    debugPrint('Cancelled all reminders for medication $medicationId');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _notifications.pendingNotificationRequests();
  }

  /// Show test notification immediately
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999999,
      'Test Notification',
      'Notifications are working correctly!',
      notificationDetails,
    );

    final pending = await _notifications.pendingNotificationRequests();
    debugPrint('Pending after test notification: ${pending.length}');
    debugPrint('Showed test notification');
  }

  /// Schedule a test notification for 1 minute from now
  Future<void> scheduleTestNotificationIn1Minute() async {
    await initialize();

    final now = DateTime.now();
    final scheduledTime = now.add(const Duration(minutes: 1));
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    debugPrint('⏰ Scheduling test notification for: ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}');
    debugPrint('⏰ Current time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}');

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders_v2',
      'Medication Reminders',
      channelDescription: 'Test scheduled notification',
      importance: Importance.max,
      priority: Priority.max,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      888888,
      'Test Scheduled Notification',
      'This should appear in 1 minute! Time: ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}',
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('✅ Test notification scheduled for 1 minute from now');
  }

  /// Generate unique notification ID for medication reminder
  /// Format: medicationId * 10 + reminderIndex
  /// Example: medication 5, reminder 2 = ID 52
  int _generateNotificationId(int medicationId, int reminderIndex) {
    return medicationId * 10 + reminderIndex;
  }

  /// Generate unique ID for low stock notifications
  /// Format: medicationId * 10 + 8
  /// Example: medication 5 = ID 58
  int _generateLowStockId(int medicationId) {
    return medicationId * 10 + 8;
  }

  /// Generate unique ID for snooze notifications
  /// Format: medicationId * 10 + 9
  /// Example: medication 5 = ID 59
  int _generateSnoozeId(int medicationId) {
    return medicationId * 10 + 9;
  }

  /// Generate unique ID for recurring reminder notifications
  /// Format: medicationId * 1000 + reminderIndex * 10 + escalationLevel
  /// Example: medication 5, reminder 2, escalation 1 = ID 5021
  int _generateRecurringReminderId(int medicationId, int reminderIndex, int escalationLevel) {
    return medicationId * 1000 + reminderIndex * 10 + escalationLevel;
  }

  /// Schedule recurring reminders for a missed dose
  /// Escalates at configured intervals: reminderInterval, reminderInterval*2, reminderInterval*3, etc.
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

    debugPrint('📱 Scheduling recurring reminders for $medicationName');
    debugPrint('   → Interval: $intervalMinutes minutes');
    debugPrint('   → Max reminders: $maxReminders');

    // Cancel any existing recurring reminders for this medication/reminder time
    await cancelRecurringReminders(medicationId, reminderIndex);

    // Schedule escalating reminders
    for (var i = 0; i < maxReminders; i++) {
      final escalationLevel = i + 1;
      final minutesFromNow = intervalMinutes * escalationLevel;
      final notificationId = _generateRecurringReminderId(medicationId, reminderIndex, escalationLevel);

      await _scheduleRecurringReminder(
        id: notificationId,
        medicationId: medicationId,
        medicationName: medicationName,
        dose: dose,
        minutesFromNow: minutesFromNow,
        escalationLevel: escalationLevel,
        customSoundPath: customSoundPath,
      );
    }

    debugPrint('✅ Scheduled $maxReminders recurring reminders for $medicationName');
  }

  /// Schedule a single recurring reminder at specified time from now
  Future<void> _scheduleRecurringReminder({
    required int id,
    required int medicationId,
    required String medicationName,
    required String dose,
    required int minutesFromNow,
    required int escalationLevel,
    String? customSoundPath,
  }) async {
    await initialize();

    final scheduledTime = DateTime.now().add(Duration(minutes: minutesFromNow));
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    debugPrint('⏰ Scheduling recurring reminder #$escalationLevel');
    debugPrint('   → Will fire in: $minutesFromNow minutes');
    debugPrint('   → At: ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}');

    final payload = json.encode({
      'type': 'recurring_reminder',
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dose': dose,
      'escalationLevel': escalationLevel,
    });

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders_v2',
      'Medication Reminders',
      channelDescription: 'Recurring reminders for missed medication doses',
      importance: Importance.max,
      priority: Priority.max,
      enableLights: true,
      color: Color(0xFFFF5722), // Orange color for recurring reminders
      ledColor: Color(0xFFFF5722),
      ledOnMs: 1000,
      ledOffMs: 500,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'take',
          'Take Now',
        ),
        AndroidNotificationAction(
          'skip',
          'Skip',
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'recurring_reminder',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      '⚠️ Missed Dose: $medicationName',
      "You haven't taken $dose yet. Please take it now. (Reminder #$escalationLevel)",
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint('✅ Scheduled recurring reminder #$escalationLevel for $medicationName');
  }

  /// Cancel all recurring reminders for a specific medication and reminder time
  Future<void> cancelRecurringReminders(int medicationId, int reminderIndex) async {
    debugPrint('🗑️ Cancelling recurring reminders for medication $medicationId, reminder $reminderIndex');

    // Cancel up to 10 possible escalation levels (should be more than enough)
    for (var i = 1; i <= 10; i++) {
      final notificationId = _generateRecurringReminderId(medicationId, reminderIndex, i);
      await _notifications.cancel(notificationId);
    }

    debugPrint('✅ Cancelled recurring reminders');
  }

  /// Cancel all recurring reminders for a medication (all reminder times)
  Future<void> cancelAllRecurringRemindersForMedication(int medicationId) async {
    debugPrint('🗑️ Cancelling all recurring reminders for medication $medicationId');

    // For each possible reminder time (0-5)
    for (var reminderIndex = 0; reminderIndex < 6; reminderIndex++) {
      // Cancel up to 10 escalation levels
      for (var escalationLevel = 1; escalationLevel <= 10; escalationLevel++) {
        final notificationId = _generateRecurringReminderId(medicationId, reminderIndex, escalationLevel);
        await _notifications.cancel(notificationId);
      }
    }

    debugPrint('✅ Cancelled all recurring reminders for medication');
  }

  Future<void> openExactAlarmSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    await intent.launch();
  }

  /// Opens the Android notification channel settings for this app
  /// This allows users to control sound, vibration, importance, etc.
  Future<void> openChannelSettings({String channelId = 'medication_reminders_v2'}) async {
    const intent = AndroidIntent(
      action: 'android.settings.CHANNEL_NOTIFICATION_SETTINGS',
      arguments: <String, dynamic>{
        'android.provider.extra.APP_PACKAGE': 'com.example.med_assist', // change to your package id
        'android.provider.extra.CHANNEL_ID': 'medication_reminders_v2',
      },
    );
    await intent.launch();
  }

  /// Opens the medication reminder channel settings specifically
  /// This is where users can enable/disable sound, vibration, etc.
  Future<void> openMedicationReminderSoundSettings() async {
    await openChannelSettings();
  }

  /// Request to disable battery optimization for the app
  /// This helps ensure notifications work reliably on Samsung and other devices
  Future<void> requestBatteryOptimizationExemption() async {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
      data: 'package:com.example.med_assist', // change to your package id
    );
    await intent.launch();
  }

  /// Check if battery optimization is disabled for the app
  Future<bool> isBatteryOptimizationDisabled() async {
    // This requires checking via platform channels
    // For now, we'll just return true
    // TODO: Implement native check
    return true;
  }

  /// Open app notification settings
  Future<void> openAppNotificationSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.APP_NOTIFICATION_SETTINGS',
      arguments: <String, dynamic>{
        'android.provider.extra.APP_PACKAGE': 'com.example.med_assist',
      },
    );
    await intent.launch();
  }

  /// Get detailed notification diagnostics
  Future<Map<String, dynamic>> getDiagnostics() async {
    final pending = await getPendingNotifications();
    final notificationsEnabled = await areNotificationsEnabled();
    final canScheduleExact = await canScheduleExactAlarms();
    final now = DateTime.now();

    final diagnostics = {
      'notificationsEnabled': notificationsEnabled,
      'canScheduleExactAlarms': canScheduleExact,
      'pendingNotificationsCount': pending.length,
      'pendingNotifications': pending.map((p) => {
        'id': p.id,
        'title': p.title,
        'body': p.body,
        'payload': p.payload,
      }).toList(),
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
    debugPrint('Device Time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    for (final p in pending) {
      debugPrint('  - ID: ${p.id}, Title: ${p.title}, Body: ${p.body}');
    }
    debugPrint('================================');

    return diagnostics;
  }

  /// Manually set timezone (for troubleshooting)
  Future<bool> setTimezone(String timezoneName) async {
    try {
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
      debugPrint('✅ Manually set timezone to: $timezoneName');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to set timezone to $timezoneName: $e');
      return false;
    }
  }

  /// Get list of common timezones
  List<String> getCommonTimezones() {
    return [
      'Asia/Riyadh',      // Saudi Arabia (GMT+3)
      'Asia/Dubai',       // UAE (GMT+4)
      'Africa/Cairo',     // Egypt (GMT+2)
      'Asia/Baghdad',     // Iraq (GMT+3)
      'Asia/Kuwait',      // Kuwait (GMT+3)
      'Asia/Qatar',       // Qatar (GMT+3)
      'Asia/Bahrain',     // Bahrain (GMT+3)
      'Europe/London',    // UK (GMT+0)
      'Europe/Paris',     // France/Germany (GMT+1)
      'America/New_York', // US East (GMT-5)
      'America/Chicago',  // US Central (GMT-6)
      'America/Los_Angeles', // US West (GMT-8)
      'Asia/Tokyo',       // Japan (GMT+9)
      'Australia/Sydney', // Australia (GMT+10)
      'UTC',              // UTC (GMT+0)
    ];
  }

}
