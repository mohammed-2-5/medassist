import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/repetition_pattern_utils.dart';
import 'package:med_assist/features/home/models/dose_event.dart';

/// Generates [DoseEvent]s from stored medications and their reminder times.
class DoseEventGenerator {
  /// Generate today's dose events from medications.
  List<DoseEvent> generateTodayDoses(
    List<MedicationWithReminders> medications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final doseEvents = <DoseEvent>[];

    for (final medWithReminders in medications) {
      final med = medWithReminders.medication;

      if (!_isActiveOnDate(med, today)) continue;

      for (var i = 0; i < medWithReminders.reminderTimes.length; i++) {
        final rt = medWithReminders.reminderTimes[i];
        final timeOfDay = TimeOfDay(hour: rt.hour, minute: rt.minute);

        doseEvents.add(
          DoseEvent(
            id: _doseId(med.id, today, i),
            medicationId: med.id.toString(),
            medicationName: med.medicineName,
            dosage: _formatDosage(med),
            time: _formatTime(timeOfDay),
            status: _determineDoseStatus(timeOfDay, now),
            instructions: med.notes,
            stockRemaining: med.stockQuantity,
          ),
        );
      }
    }

    doseEvents.sort((a, b) => _parseTime(a.time).compareTo(_parseTime(b.time)));
    return doseEvents;
  }

  /// Generate doses for a week starting at [startOfWeek].
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

  /// Calculate adherence percentage.
  double calculateAdherence(int takenCount, int totalCount) {
    if (totalCount == 0) return 0;
    return (takenCount / totalCount) * 100;
  }

  /// Warnings for medications that are running low or out of stock.
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

      final dailyUsage = med.dosePerTime * med.timesPerDay;
      if (dailyUsage <= 0) continue;
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

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Consistent dose ID across all generators: `medId_yyyyMMdd_reminderIndex`.
  static String _doseId(int medId, DateTime date, int reminderIndex) {
    final d =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return '${medId}_${d}_$reminderIndex';
  }

  /// Whether the medication should have doses on [date], considering its
  /// start/end date window **and** repetition pattern.
  bool _isActiveOnDate(Medication med, DateTime date) {
    final startDate = DateTime(
      med.startDate.year,
      med.startDate.month,
      med.startDate.day,
    );
    final endDate = startDate.add(Duration(days: med.durationDays));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isBefore(startDate) || dateOnly.isAfter(endDate)) {
      return false;
    }

    return RepetitionPatternUtils.isDoseDay(
      pattern: med.repetitionPattern,
      specificDaysOfWeek: med.specificDaysOfWeek,
      startDate: med.startDate,
      date: date,
      intervalDays: med.intervalDays,
      intervalWeeks: med.intervalWeeks,
      intervalMonths: med.intervalMonths,
      dayOfMonth: med.dayOfMonth,
    );
  }

  List<DoseEvent> _generateDosesForDate(
    List<MedicationWithReminders> medications,
    DateTime date,
  ) {
    final doseEvents = <DoseEvent>[];

    for (final medWithReminders in medications) {
      final med = medWithReminders.medication;

      if (!_isActiveOnDate(med, date)) continue;

      for (var i = 0; i < medWithReminders.reminderTimes.length; i++) {
        final rt = medWithReminders.reminderTimes[i];
        final timeOfDay = TimeOfDay(hour: rt.hour, minute: rt.minute);

        doseEvents.add(
          DoseEvent(
            id: _doseId(med.id, date, i),
            medicationId: med.id.toString(),
            medicationName: med.medicineName,
            dosage: _formatDosage(med),
            time: _formatTime(timeOfDay),
            status: DoseStatus.pending,
            instructions: med.notes,
            stockRemaining: med.stockQuantity,
          ),
        );
      }
    }

    return doseEvents;
  }

  String _formatDosage(Medication med) {
    final amount = med.dosePerTime;
    final amountStr = amount == amount.toInt()
        ? amount.toInt().toString()
        : amount.toString();
    final unitStr = amount > 1 && !med.doseUnit.endsWith('s')
        ? '${med.doseUnit}s'
        : med.doseUnit;
    return '$amountStr $unitStr';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  DoseStatus _determineDoseStatus(TimeOfDay scheduledTime, DateTime now) {
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (now.isBefore(scheduled)) return DoseStatus.pending;
    if (now.difference(scheduled).inHours < 2) return DoseStatus.pending;
    return DoseStatus.missed;
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = parts[1] == 'PM';

    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }

    return DateTime(2000, 1, 1, hour, minute);
  }
}
