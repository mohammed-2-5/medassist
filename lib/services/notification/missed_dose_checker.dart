import 'package:flutter/foundation.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// Service to check for missed doses and trigger recurring reminders
class MissedDoseChecker {
  factory MissedDoseChecker() => _instance;
  MissedDoseChecker._internal();
  static final MissedDoseChecker _instance = MissedDoseChecker._internal();

  final NotificationService _notificationService = NotificationService();
  final AppDatabase _database = AppDatabase();

  /// Check for missed doses and schedule recurring reminders if needed
  /// This should be called:
  /// - When the app starts
  /// - When the app resumes from background
  /// - Periodically (e.g., every hour)
  Future<void> checkMissedDoses() async {
    try {
      debugPrint('🔍 Checking for missed doses...');

      // Get all active medications
      final medications = await _database.getAllMedications();
      final now = DateTime.now();

      var missedDosesFound = 0;

      for (final medication in medications) {
        // Skip if medication is not active or doesn't have recurring reminders enabled
        if (!medication.isActive || !medication.enableRecurringReminders) {
          continue;
        }

        // Get reminder times for this medication
        final reminderTimes = await _database.getReminderTimes(medication.id);

        for (var i = 0; i < reminderTimes.length; i++) {
          final reminderTime = reminderTimes[i];

          // Calculate the last scheduled time for this reminder
          final lastScheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            reminderTime.hour,
            reminderTime.minute,
          );

          // If the scheduled time hasn't passed today, skip
          if (lastScheduledTime.isAfter(now)) {
            continue;
          }

          // Check if dose was taken or skipped for this reminder time
          final wasDoseTaken = await _wasDoseTakenOrSkipped(
            medication.id,
            lastScheduledTime,
          );

          if (!wasDoseTaken) {
            // Calculate how many minutes have passed since the scheduled time
            final minutesSinceScheduled = now.difference(lastScheduledTime).inMinutes;

            // Only trigger recurring reminders if it's been at least the configured interval
            // and less than 24 hours (to avoid triggering for very old missed doses)
            if (minutesSinceScheduled >= medication.recurringReminderInterval &&
                minutesSinceScheduled < 1440) {
              debugPrint('📱 Missed dose detected for ${medication.medicineName}');
              debugPrint('   → Scheduled time: ${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}');
              debugPrint('   → Minutes since scheduled: $minutesSinceScheduled');

              // Schedule recurring reminders
              await _notificationService.scheduleRecurringReminders(
                medicationId: medication.id,
                reminderIndex: i,
                medicationName: medication.medicineName,
                dose: '${medication.dosePerTime} ${medication.doseUnit}',
                intervalMinutes: medication.recurringReminderInterval,
                customSoundPath: medication.customSoundPath,
              );

              missedDosesFound++;
            }
          }
        }
      }

      if (missedDosesFound > 0) {
        debugPrint('✅ Found $missedDosesFound missed doses and scheduled recurring reminders');
      } else {
        debugPrint('✅ No missed doses found');
      }
    } catch (e, stack) {
      debugPrint('❌ Error checking for missed doses: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  /// Check if a dose was taken or skipped for the given medication and time
  Future<bool> _wasDoseTakenOrSkipped(
    int medicationId,
    DateTime scheduledTime,
  ) async {
    try {
      // Query dose history for this medication and scheduled time
      final doseHistory = await _database.findDoseRecord(
        medicationId: medicationId,
        scheduledDate: scheduledTime,
        scheduledHour: scheduledTime.hour,
        scheduledMinute: scheduledTime.minute,
      );

      // Check if there's a record and it's either taken or skipped
      if (doseHistory != null) {
        return doseHistory.status == 'taken' || doseHistory.status == 'skipped';
      }

      return false;
    } catch (e) {
      debugPrint('Error checking dose history: $e');
      return false;
    }
  }

  /// Force check for missed doses now (can be called manually)
  Future<void> forceCheck() async {
    debugPrint('🔄 Force checking for missed doses...');
    await checkMissedDoses();
  }
}
