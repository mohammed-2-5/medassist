import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/services/notification/notification_service.dart';
import 'package:workmanager/workmanager.dart';

/// Background task names
const String kDailyTaskName = 'daily_medication_check';
const String kDailyTaskIdentifier = 'dailyMedicationCheckTask';
const String kHourlyTaskName = 'hourly_missed_dose_check';
const String kHourlyTaskIdentifier = 'hourlyMissedDoseCheckTask';

/// Top-level callback dispatcher for WorkManager
/// Must be a top-level function or static method
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint('Background task started: $task');

      switch (task) {
        case kDailyTaskIdentifier:
          await _handleDailyTask();
        case kHourlyTaskIdentifier:
          await _handleHourlyTask();
        default:
          debugPrint('Unknown task: $task');
      }

      debugPrint('Background task completed: $task');
      return true;
    } catch (e) {
      debugPrint('Background task failed: $e');
      return false;
    }
  });
}

/// Handle hourly background task
/// Runs every hour to check for missed doses
Future<void> _handleHourlyTask() async {
  try {
    debugPrint('Hourly task started: checking for missed doses');
    final db = AppDatabase();
    await _updateMissedDoses(db);
    debugPrint('Hourly task completed successfully');
  } catch (e) {
    debugPrint('Error in hourly task: $e');
    rethrow;
  }
}

/// Handle daily background task
/// Runs at midnight to:
/// - Update missed doses
/// - Check stock levels
/// - Calculate adherence stats
Future<void> _handleDailyTask() async {
  try {
    // Initialize database
    final db = AppDatabase();
    final notificationService = NotificationService();

    // 1. Update missed doses
    await _updateMissedDoses(db);

    // 2. Check stock levels and schedule notifications
    await _checkStockLevels(db, notificationService);

    // 3. Calculate daily adherence
    await _calculateDailyAdherence(db);

    debugPrint('Daily task completed successfully');
  } catch (e) {
    debugPrint('Error in daily task: $e');
    rethrow;
  }
}

/// Update missed doses
/// Checks for scheduled doses that are >2 hours past scheduled time
/// and have no dose history record, then marks them as missed
Future<void> _updateMissedDoses(AppDatabase db) async {
  try {
    debugPrint('Checking for missed doses...');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get all active medications with their reminder times
    final medicationsWithReminders = await db.getMedicationsWithReminders();

    // Get today's dose history
    final todayHistory = await db.getDoseHistoryForDate(today);

    var missedCount = 0;

    // Check each medication's scheduled doses
    for (final medWithReminders in medicationsWithReminders) {
      final medication = medWithReminders.medication;
      final reminderTimes = medWithReminders.reminderTimes;

      // Check each reminder time
      for (final reminderTime in reminderTimes) {
        // Create scheduled time for today
        final scheduledTime = DateTime(
          today.year,
          today.month,
          today.day,
          reminderTime.hour,
          reminderTime.minute,
        );

        // Calculate time difference
        final timeDifference = now.difference(scheduledTime);

        // Only process if >2 hours late and scheduled time is in the past
        if (timeDifference.inHours >= 2 && scheduledTime.isBefore(now)) {
          // Check if there's already a history record for this dose
          final existingRecord = todayHistory.cast<DoseHistoryData?>().firstWhere(
            (h) =>
                h != null &&
                h.medicationId == medication.id &&
                h.scheduledHour == reminderTime.hour &&
                h.scheduledMinute == reminderTime.minute,
            orElse: () => null,
          );

          // If no history record exists, mark as missed
          if (existingRecord == null) {
            try {
              await db.recordDoseMissed(
                medicationId: medication.id,
                scheduledDate: today,
                scheduledHour: reminderTime.hour,
                scheduledMinute: reminderTime.minute,
                notes: 'Auto-marked as missed by background service',
              );
              missedCount++;
              debugPrint(
                'Marked dose as missed: ${medication.medicineName} at ${reminderTime.hour}:${reminderTime.minute}',
              );
            } catch (e) {
              debugPrint('Error recording missed dose: $e');
            }
          }
        }
      }
    }

    debugPrint('Missed doses check completed: $missedCount doses marked as missed');
  } catch (e) {
    debugPrint('Error updating missed doses: $e');
  }
}

/// Check stock levels and schedule notifications
Future<void> _checkStockLevels(
  AppDatabase db,
  NotificationService notificationService,
) async {
  try {
    final medications = await db.getActiveMedications();

    for (final medication in medications) {
      // Calculate daily usage: timesPerDay * dosePerTime
      final dailyUsage = medication.timesPerDay * medication.dosePerTime;

      // Calculate days remaining
      final daysRemaining = dailyUsage > 0
          ? (medication.stockQuantity / dailyUsage).floor()
          : 999; // Effectively infinite if no daily usage

      // Schedule low stock notification if ≤3 days remaining
      if (daysRemaining > 0 && daysRemaining <= 3) {
        await notificationService.scheduleLowStockNotification(medication);
      }
    }

    debugPrint('Stock levels checked');
  } catch (e) {
    debugPrint('Error checking stock levels: $e');
  }
}


/// Calculate daily adherence statistics
Future<void> _calculateDailyAdherence(AppDatabase db) async {
  try {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final startOfYesterday = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );
    final endOfYesterday = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
      23,
      59,
      59,
    );

    // Get adherence stats for yesterday
    final stats = await db.getAdherenceStats(startOfYesterday, endOfYesterday);

    final takenDoses = stats['taken'] ?? 0;
    final skippedDoses = stats['skipped'] ?? 0;
    final missedDoses = stats['missed'] ?? 0;
    final totalDoses = takenDoses + skippedDoses + missedDoses;

    if (totalDoses == 0) {
      debugPrint('No doses scheduled for yesterday');
      return;
    }

    // Calculate adherence (taken / total * 100)
    final adherenceRate = (takenDoses / totalDoses * 100).round();

    debugPrint(
      'Yesterday adherence: $adherenceRate% ($takenDoses/$totalDoses doses taken)',
    );

    // Could store this in a statistics table for history
    // For now, just log it
  } catch (e) {
    debugPrint('Error calculating daily adherence: $e');
  }
}

/// Abstract interface for background task service
abstract class BackgroundService {
  /// Initialize the background service
  Future<void> initialize();

  /// Configure background tasks
  Future<void> configure();

  /// Start background tasks
  Future<void> start();

  /// Stop background tasks
  Future<void> stop();

  /// Dispose resources
  void dispose();

  /// Manually trigger daily task (for testing)
  Future<void> triggerDailyTask();
}

/// WorkManager implementation of BackgroundService
class WorkManagerBackgroundService implements BackgroundService {
  factory WorkManagerBackgroundService() => _instance;
  WorkManagerBackgroundService._internal();
  static final WorkManagerBackgroundService _instance =
      WorkManagerBackgroundService._internal();

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('BackgroundService already initialized');
      return;
    }

    try {
      debugPrint('Initializing BackgroundService...');

      // Initialize WorkManager with callback dispatcher
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      _isInitialized = true;
      debugPrint('BackgroundService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing BackgroundService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  @override
  Future<void> configure() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      debugPrint('Configuring background tasks...');

      // Register hourly periodic task for missed dose detection
      // Runs every 1 hour (Android minimum is 15 minutes)
      await Workmanager().registerPeriodicTask(
        kHourlyTaskName,
        kHourlyTaskIdentifier,
        frequency: const Duration(hours: 1),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        initialDelay: const Duration(minutes: 15), // First run after 15 minutes
      );

      // Register daily periodic task for stock checks and adherence
      // Runs once per day
      await Workmanager().registerPeriodicTask(
        kDailyTaskName,
        kDailyTaskIdentifier,
        frequency: const Duration(hours: 24),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        initialDelay: const Duration(hours: 1), // First run after 1 hour
      );

      debugPrint('Background tasks registered: hourly + daily');
    } catch (e) {
      debugPrint('Error configuring background tasks: $e');
      rethrow;
    }
  }

  @override
  Future<void> start() async {
    if (!_isInitialized) {
      await configure();
    }
    debugPrint('BackgroundService started');
  }

  @override
  Future<void> stop() async {
    try {
      debugPrint('Stopping background tasks...');
      await Workmanager().cancelAll();
      debugPrint('All background tasks cancelled');
    } catch (e) {
      debugPrint('Error stopping background tasks: $e');
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    debugPrint('BackgroundService disposed');
  }

  @override
  Future<void> triggerDailyTask() async {
    try {
      debugPrint('Manually triggering daily task...');

      // Register one-time task
      await Workmanager().registerOneOffTask(
        'test_daily_task',
        kDailyTaskIdentifier,
        initialDelay: const Duration(seconds: 5),
      );

      debugPrint('Daily task triggered (will run in 5 seconds)');
    } catch (e) {
      debugPrint('Error triggering daily task: $e');
      rethrow;
    }
  }
}
