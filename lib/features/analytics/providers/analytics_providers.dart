import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';

/// Helper to convert scheduled date/hour/minute to DateTime
DateTime _getScheduledDateTime(DoseHistoryData dose) {
  return DateTime(
    dose.scheduledDate.year,
    dose.scheduledDate.month,
    dose.scheduledDate.day,
    dose.scheduledHour,
    dose.scheduledMinute,
  );
}

/// Provider for weekly adherence data (last 7 days)
final weeklyAdherenceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.watch(appDatabaseProvider);

  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));

  // Get all dose history for the last 7 days
  final allHistory = await database.getAllDoseHistory();
  final weekHistory = allHistory.where((DoseHistoryData dose) {
    final scheduledTime = _getScheduledDateTime(dose);
    return scheduledTime.isAfter(weekAgo);
  }).toList();

  // Group by day
  final dailyData = <String, Map<String, int>>{};

  for (var i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dayKey = '${date.month}/${date.day}';

    final dayDoses = weekHistory.where((DoseHistoryData dose) {
      final doseDate = dose.scheduledDate;
      return doseDate.year == date.year &&
             doseDate.month == date.month &&
             doseDate.day == date.day;
    });

    dailyData[dayKey] = {
      'taken': dayDoses.where((DoseHistoryData d) => d.status == 'taken').length,
      'missed': dayDoses.where((DoseHistoryData d) => d.status == 'missed').length,
      'total': dayDoses.length,
    };
  }

  return {'dailyData': dailyData, 'weekHistory': weekHistory};
});

/// Provider for current streak (consecutive days with 100% adherence)
final currentStreakProvider = FutureProvider<int>((ref) async {
  final database = ref.watch(appDatabaseProvider);

  final now = DateTime.now();
  var streak = 0;
  var checkDate = now;

  // Check each day going backwards
  for (var i = 0; i < 365; i++) {
    final startOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
    final endOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day, 23, 59, 59);

    // Get doses for this day
    final allHistory = await database.getAllDoseHistory();
    final dayDoses = allHistory.where((DoseHistoryData dose) {
      final scheduledTime = _getScheduledDateTime(dose);
      return scheduledTime.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
             scheduledTime.isBefore(endOfDay.add(const Duration(seconds: 1)));
    }).toList();

    if (dayDoses.isEmpty) {
      // No doses scheduled, don't break streak
      checkDate = checkDate.subtract(const Duration(days: 1));
      continue;
    }

    // Check if all doses were taken
    final allTaken = dayDoses.every((DoseHistoryData d) => d.status == 'taken');

    if (allTaken) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  return streak;
});

/// Provider for overall statistics
final overallStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.watch(appDatabaseProvider);

  // Get all dose history
  final allHistory = await database.getAllDoseHistory();

  final totalDoses = allHistory.length;
  final takenDoses = allHistory.where((DoseHistoryData d) => d.status == 'taken').length;
  final missedDoses = allHistory.where((DoseHistoryData d) => d.status == 'missed').length;
  final skippedDoses = allHistory.where((DoseHistoryData d) => d.status == 'skipped').length;

  final overallAdherence = totalDoses > 0
      ? (takenDoses / totalDoses * 100).round()
      : 0;

  // Calculate average delay for taken doses
  final takenWithTime = allHistory
      .where((DoseHistoryData d) => d.status == 'taken' && d.actualTime != null)
      .toList();

  var totalDelayMinutes = 0.0;
  for (final dose in takenWithTime) {
    final scheduledTime = _getScheduledDateTime(dose);
    final delay = dose.actualTime!.difference(scheduledTime);
    totalDelayMinutes += delay.inMinutes.abs();
  }

  final avgDelayMinutes = takenWithTime.isNotEmpty
      ? (totalDelayMinutes / takenWithTime.length).round()
      : 0;

  // Get active medications
  final medications = await database.getActiveMedications();
  final activeMedicationsCount = medications.length;

  return {
    'totalDoses': totalDoses,
    'takenDoses': takenDoses,
    'missedDoses': missedDoses,
    'skippedDoses': skippedDoses,
    'overallAdherence': overallAdherence,
    'avgDelayMinutes': avgDelayMinutes,
    'activeMedicationsCount': activeMedicationsCount,
  };
});

/// Provider for monthly trends (last 6 months)
final monthlyTrendsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final database = ref.watch(appDatabaseProvider);

  final now = DateTime.now();
  final trends = <Map<String, dynamic>>[];

  for (var i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final monthStart = DateTime(month.year, month.month);
    final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    // Get doses for this month
    final allHistory = await database.getAllDoseHistory();
    final monthDoses = allHistory.where((DoseHistoryData dose) {
      final scheduledTime = _getScheduledDateTime(dose);
      return scheduledTime.isAfter(monthStart.subtract(const Duration(seconds: 1))) &&
             scheduledTime.isBefore(monthEnd.add(const Duration(seconds: 1)));
    }).toList();

    final total = monthDoses.length;
    final taken = monthDoses.where((DoseHistoryData d) => d.status == 'taken').length;
    final adherence = total > 0 ? (taken / total * 100).round() : 0;

    trends.add({
      'month': '${_getMonthName(month.month)} ${month.year}',
      'monthShort': _getMonthShort(month.month),
      'adherence': adherence,
      'total': total,
      'taken': taken,
    });
  }

  return trends;
});

/// Provider for medication-specific analytics
final medicationAnalyticsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final database = ref.watch(appDatabaseProvider);

  final medications = await database.getAllMedications();
  final allHistory = await database.getAllDoseHistory();

  final results = <Map<String, dynamic>>[];

  for (final med in medications) {
    final medDoses = allHistory.where((DoseHistoryData d) => d.medicationId == med.id).toList();

    if (medDoses.isEmpty) continue;

    final total = medDoses.length;
    final taken = medDoses.where((DoseHistoryData d) => d.status == 'taken').length;
    final adherence = (taken / total * 100).round();

    results.add({
      'medication': med,
      'total': total,
      'taken': taken,
      'missed': medDoses.where((DoseHistoryData d) => d.status == 'missed').length,
      'adherence': adherence,
    });
  }

  // Sort by adherence (lowest first for attention)
  results.sort((a, b) => (a['adherence'] as int).compareTo(b['adherence'] as int));

  return results;
});

String _getMonthName(int month) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[month - 1];
}

String _getMonthShort(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month - 1];
}
