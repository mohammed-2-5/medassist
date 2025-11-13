import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/home/models/dose_event.dart';

/// Service to generate dose events from database medications
class DoseEventGenerator {
  /// Generate today's dose events from medications
  List<DoseEvent> generateTodayDoses(
    List<MedicationWithReminders> medications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final doseEvents = <DoseEvent>[];

    for (final medWithReminders in medications) {
      final med = medWithReminders.medication;
      final reminderTimes = medWithReminders.reminderTimes;

      // Check if medication should have doses today
      final startDate = DateTime(
        med.startDate.year,
        med.startDate.month,
        med.startDate.day,
      );
      final endDate = startDate.add(Duration(days: med.durationDays));

      // Skip if today is before start date or after end date
      if (today.isBefore(startDate) || today.isAfter(endDate)) {
        continue;
      }

      // Generate dose events for each reminder time
      for (var i = 0; i < reminderTimes.length; i++) {
        final reminderTime = reminderTimes[i];
        final timeOfDay = TimeOfDay(
          hour: reminderTime.hour,
          minute: reminderTime.minute,
        );

        // Create dose event
        final doseEvent = DoseEvent(
          id: '${med.id}_$i',
          medicationId: med.id.toString(),
          medicationName: med.medicineName,
          dosage: _formatDosage(med),
          time: _formatTime(timeOfDay),
          status: _determineDoseStatus(timeOfDay, now),
          instructions: med.notes,
          stockRemaining: med.stockQuantity,
        );

        doseEvents.add(doseEvent);
      }
    }

    // Sort by time
    doseEvents.sort((a, b) {
      final aTime = _parseTime(a.time);
      final bTime = _parseTime(b.time);
      return aTime.compareTo(bTime);
    });

    return doseEvents;
  }

  /// Format dosage string
  String _formatDosage(Medication med) {
    final amount = med.dosePerTime;
    final unit = med.doseUnit;

    // Format amount nicely
    final amountStr = amount == amount.toInt()
        ? amount.toInt().toString()
        : amount.toString();

    // Pluralize unit if needed
    final unitStr = amount > 1 && !unit.endsWith('s') ? '${unit}s' : unit;

    return '$amountStr $unitStr';
  }

  /// Format time as string
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Determine dose status based on time
  DoseStatus _determineDoseStatus(TimeOfDay scheduledTime, DateTime now) {
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (now.isBefore(scheduled)) {
      return DoseStatus.pending;
    } else if (now.difference(scheduled).inHours < 2) {
      // Within 2 hours of scheduled time - still pending
      return DoseStatus.pending;
    } else {
      // More than 2 hours past - marked as missed
      return DoseStatus.missed;
    }
  }

  /// Parse time string back to DateTime for sorting
  DateTime _parseTime(String timeStr) {
    // Format: "8:00 AM" or "12:30 PM"
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = parts[1] == 'PM';

    var hour24 = hour;
    if (isPM && hour != 12) {
      hour24 += 12;
    } else if (!isPM && hour == 12) {
      hour24 = 0;
    }

    return DateTime(2000, 1, 1, hour24, minute);
  }

  /// Generate week view doses (for calendar/week view)
  Map<DateTime, List<DoseEvent>> generateWeekDoses(
    List<MedicationWithReminders> medications,
    DateTime startOfWeek,
  ) {
    final weekDoses = <DateTime, List<DoseEvent>>{};

    for (var i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayDoses = _generateDosesForDate(medications, date);
      if (dayDoses.isNotEmpty) {
        weekDoses[date] = dayDoses;
      }
    }

    return weekDoses;
  }

  /// Generate doses for a specific date
  List<DoseEvent> _generateDosesForDate(
    List<MedicationWithReminders> medications,
    DateTime date,
  ) {
    final doseEvents = <DoseEvent>[];
    final dateOnly = DateTime(date.year, date.month, date.day);

    for (final medWithReminders in medications) {
      final med = medWithReminders.medication;
      final reminderTimes = medWithReminders.reminderTimes;

      // Check if medication is active on this date
      final startDate = DateTime(
        med.startDate.year,
        med.startDate.month,
        med.startDate.day,
      );
      final endDate = startDate.add(Duration(days: med.durationDays));

      if (dateOnly.isBefore(startDate) || dateOnly.isAfter(endDate)) {
        continue;
      }

      // Generate dose events
      for (var i = 0; i < reminderTimes.length; i++) {
        final reminderTime = reminderTimes[i];
        final timeOfDay = TimeOfDay(
          hour: reminderTime.hour,
          minute: reminderTime.minute,
        );

        final doseEvent = DoseEvent(
          id: '${med.id}_${date.millisecondsSinceEpoch}_$i',
          medicationId: med.id.toString(),
          medicationName: med.medicineName,
          dosage: _formatDosage(med),
          time: _formatTime(timeOfDay),
          status: DoseStatus.pending,
          instructions: med.notes,
          stockRemaining: med.stockQuantity,
        );

        doseEvents.add(doseEvent);
      }
    }

    return doseEvents;
  }

  /// Calculate adherence for a date range
  double calculateAdherence(
    int takenCount,
    int totalCount,
  ) {
    if (totalCount == 0) return 0;
    return (takenCount / totalCount) * 100;
  }

  /// Get low stock warnings
  List<String> getLowStockWarnings(
    List<MedicationWithReminders> medications,
  ) {
    final warnings = <String>[];

    for (final medWithReminders in medications) {
      final med = medWithReminders.medication;

      if (med.stockQuantity <= 0) {
        warnings.add('${med.medicineName} is out of stock');
        continue;
      }

      // Calculate days remaining
      final dailyUsage = med.dosePerTime * med.timesPerDay;
      final daysRemaining = (med.stockQuantity / dailyUsage).floor();

      if (daysRemaining <= 0) {
        warnings.add('${med.medicineName} is out of stock');
      } else if (daysRemaining <= med.reminderDaysBeforeRunOut) {
        warnings.add(
          '${med.medicineName} - Only $daysRemaining day${daysRemaining != 1 ? 's' : ''} remaining',
        );
      }
    }

    return warnings;
  }
}
