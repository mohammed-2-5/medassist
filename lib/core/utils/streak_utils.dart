import 'package:med_assist/core/database/app_database.dart';

/// Shared streak calculation logic.
class StreakUtils {
  const StreakUtils._();

  /// Calculate the best (longest) streak ever achieved.
  static int bestStreak(List<DoseHistoryData> allHistory) {
    if (allHistory.isEmpty) return 0;

    final dailyAdherence = <DateTime, bool>{};
    for (final dose in allHistory) {
      final dateKey = DateTime(
        dose.scheduledDate.year,
        dose.scheduledDate.month,
        dose.scheduledDate.day,
      );
      dailyAdherence.putIfAbsent(dateKey, () => true);
      if (dose.status != 'taken') dailyAdherence[dateKey] = false;
    }

    var best = 0;
    var temp = 0;
    DateTime? lastDate;
    final sortedDates = dailyAdherence.keys.toList()..sort();

    for (final date in sortedDates) {
      if (dailyAdherence[date] ?? false) {
        if (lastDate == null || date.difference(lastDate).inDays == 1) {
          temp++;
          if (temp > best) best = temp;
        } else {
          temp = 1;
        }
        lastDate = date;
      } else {
        temp = 0;
      }
    }

    return best;
  }

  /// Calculate the current streak (consecutive days with 100% adherence)
  /// by walking backwards from today.
  static int currentStreak(List<DoseHistoryData> allHistory) {
    if (allHistory.isEmpty) return 0;

    // Group by date and check all-taken per day
    final dailyAdherence = <DateTime, bool>{};
    for (final dose in allHistory) {
      final dateKey = DateTime(
        dose.scheduledDate.year,
        dose.scheduledDate.month,
        dose.scheduledDate.day,
      );
      dailyAdherence.putIfAbsent(dateKey, () => true);
      if (dose.status != 'taken') {
        dailyAdherence[dateKey] = false;
      }
    }

    var streak = 0;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    for (var dayOffset = 0; dayOffset < 365; dayOffset++) {
      final checkDate = today.subtract(Duration(days: dayOffset));
      final adherence = dailyAdherence[checkDate];

      if (adherence == null) {
        if (dayOffset > 0) break;
        continue; // today with no data yet
      }

      if (adherence) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
