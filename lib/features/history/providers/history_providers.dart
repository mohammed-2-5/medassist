import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:riverpod/src/providers/future_provider.dart';

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

/// Provider for selected date in calendar (using NotifierProvider for Riverpod 3.x)
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

/// Provider for dose history for selected date
final FutureProviderFamily<List<DoseHistoryData>, DateTime> doseHistoryForDateProvider = FutureProvider.family<List<DoseHistoryData>, DateTime>(
  (ref, date) async {
    final database = ref.watch(appDatabaseProvider);

    // Get start and end of the selected day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // Get all dose history for the date
    final allHistory = await database.getAllDoseHistory();

    // Filter by date range
    return allHistory.where((DoseHistoryData dose) {
      final scheduledTime = _getScheduledDateTime(dose);
      return scheduledTime.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
             scheduledTime.isBefore(endOfDay.add(const Duration(seconds: 1)));
    }).toList()
      ..sort((a, b) {
        final aTime = _getScheduledDateTime(a);
        final bTime = _getScheduledDateTime(b);
        return aTime.compareTo(bTime);
      });
  },
);

/// Provider for monthly adherence stats
final FutureProviderFamily<Map<String, dynamic>, DateTime> monthlyAdherenceProvider = FutureProvider.family<Map<String, dynamic>, DateTime>(
  (ref, date) async {
    final database = ref.watch(appDatabaseProvider);

    // Get start and end of month
    final startOfMonth = DateTime(date.year, date.month);
    final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    // Get all dose history for the month
    final allHistory = await database.getAllDoseHistory();
    final monthHistory = allHistory.where((DoseHistoryData dose) {
      final scheduledTime = _getScheduledDateTime(dose);
      return scheduledTime.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
             scheduledTime.isBefore(endOfMonth.add(const Duration(seconds: 1)));
    }).toList();

    // Calculate stats
    final totalDoses = monthHistory.length;
    final takenDoses = monthHistory.where((DoseHistoryData d) => d.status == 'taken').length;
    final missedDoses = monthHistory.where((DoseHistoryData d) => d.status == 'missed').length;
    final skippedDoses = monthHistory.where((DoseHistoryData d) => d.status == 'skipped').length;

    final adherenceRate = totalDoses > 0
        ? (takenDoses / totalDoses * 100).round()
        : 0;

    return {
      'total': totalDoses,
      'taken': takenDoses,
      'missed': missedDoses,
      'skipped': skippedDoses,
      'adherenceRate': adherenceRate,
    };
  },
);

/// Provider for dates with doses in a month
final FutureProviderFamily<Set<DateTime>, DateTime> datesWithDosesProvider = FutureProvider.family<Set<DateTime>, DateTime>(
  (ref, date) async {
    final database = ref.watch(appDatabaseProvider);

    // Get start and end of month
    final startOfMonth = DateTime(date.year, date.month);
    final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    // Get all dose history for the month
    final allHistory = await database.getAllDoseHistory();
    final monthHistory = allHistory.where((DoseHistoryData dose) {
      final scheduledTime = _getScheduledDateTime(dose);
      return scheduledTime.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
             scheduledTime.isBefore(endOfMonth.add(const Duration(seconds: 1)));
    });

    // Extract unique dates (day only)
    final dates = monthHistory.map((DoseHistoryData dose) {
      final scheduledTime = _getScheduledDateTime(dose);
      return DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day);
    }).toSet();

    return dates;
  },
);

/// Provider for medication details with history
final FutureProviderFamily<List<Map<String, dynamic>>, DateTime> medicationHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, DateTime>(
  (ref, date) async {
    final database = ref.watch(appDatabaseProvider);

    // Get start and end of the selected day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // Get all medications
    final medications = await database.getAllMedications();

    // Get all dose history for the date
    final allHistory = await database.getAllDoseHistory();
    final dayHistory = allHistory.where((DoseHistoryData dose) {
      final scheduledTime = _getScheduledDateTime(dose);
      return scheduledTime.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
             scheduledTime.isBefore(endOfDay.add(const Duration(seconds: 1)));
    }).toList();

    // Group by medication
    final result = <Map<String, dynamic>>[];
    for (final med in medications) {
      final medDoses = dayHistory.where((DoseHistoryData d) => d.medicationId == med.id).toList();
      if (medDoses.isNotEmpty) {
        result.add({
          'medication': med,
          'doses': medDoses,
        });
      }
    }

    return result;
  },
);
