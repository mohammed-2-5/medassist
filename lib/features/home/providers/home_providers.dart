import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart'
    show DoseHistoryData;
import 'package:med_assist/core/database/models/dose_result.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/database/repositories/medication_repository.dart'
    show MedicationRepository;
import 'package:med_assist/features/home/models/dose_event.dart';
import 'package:med_assist/features/home/services/dose_event_generator.dart';
import 'package:med_assist/services/notification/notification_service.dart';

// Re-export for backwards compatibility
export 'package:med_assist/core/database/providers/database_providers.dart'
    show hasMedicationsProvider;

/// Provider for dose event generator
final doseEventGeneratorProvider = Provider<DoseEventGenerator>((ref) {
  return DoseEventGenerator();
});

/// Provider for today's dose events
final todayDosesProvider =
    NotifierProvider<TodayDosesNotifier, List<DoseEvent>>(
      TodayDosesNotifier.new,
    );

/// Notifier for managing today's doses.
///
/// All dose-recording and stock-mutation logic is delegated to
/// [MedicationRepository] which wraps operations in database transactions.
class TodayDosesNotifier extends Notifier<List<DoseEvent>> {
  bool _isRefreshing = false;

  @override
  List<DoseEvent> build() {
    _loadTodayDoses();
    return [];
  }

  Future<void> _loadTodayDoses() async {
    try {
      final medications = await ref.read(
        medicationsWithRemindersProvider.future,
      );
      final generator = ref.read(doseEventGeneratorProvider);
      final doseEvents = generator.generateTodayDoses(medications);

      final database = ref.read(appDatabaseProvider);
      final today = DateTime.now();
      final history = await database.getDoseHistoryForDate(today);

      final updatedDoses = doseEvents.map((dose) {
        final (:hour24, :minute) = _parseDoseTime(dose.time);

        final historyRecord = history
            .where(
              (h) =>
                  h.medicationId.toString() == dose.medicationId &&
                  h.scheduledHour == hour24 &&
                  h.scheduledMinute == minute,
            )
            .firstOrNull;

        if (historyRecord != null) {
          final status = switch (historyRecord.status) {
            'taken' => DoseStatus.taken,
            'skipped' => DoseStatus.skipped,
            'snoozed' => DoseStatus.snoozed,
            'missed' => DoseStatus.missed,
            _ => dose.status,
          };
          return dose.copyWith(status: status);
        }

        return dose;
      }).toList();

      state = updatedDoses;
    } catch (e) {
      debugPrint('Error loading today doses: $e');
      state = [];
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      await _loadTodayDoses();
    } finally {
      _isRefreshing = false;
    }
  }

  /// Mark dose as taken via repository (transactional, with stock deduction).
  Future<DoseResult> markAsTaken(String doseId) async {
    final dose = state.where((d) => d.id == doseId).firstOrNull;
    if (dose == null) return const DoseOperationFailed('Dose not found');

    if (dose.status == DoseStatus.taken) {
      return const DoseAlreadyRecorded();
    }

    final (:hour24, :minute) = _parseDoseTime(dose.time);

    try {
      final repository = ref.read(medicationRepositoryProvider);
      final result = await repository.takeDose(
        medicationId: int.parse(dose.medicationId),
        scheduledDate: DateTime.now(),
        scheduledHour: hour24,
        scheduledMinute: minute,
      );

      if (result is DoseRecorded || result is DoseAlreadyRecorded) {
        _updateDoseStatus(doseId, DoseStatus.taken);
      } else {
        debugPrint('takeDose returned unexpected result: $result');
      }

      return result;
    } catch (e) {
      debugPrint('Error marking dose as taken: $e');
      return DoseOperationFailed(e.toString());
    }
  }

  /// Snooze dose with specified duration.
  Future<void> snoozeDose(String doseId, {int minutes = 15}) async {
    final dose = state.where((d) => d.id == doseId).firstOrNull;
    if (dose == null) return;
    final (:hour24, :minute) = _parseDoseTime(dose.time);
    final now = DateTime.now();
    final snoozeUntil = now.add(Duration(minutes: minutes));

    try {
      final repository = ref.read(medicationRepositoryProvider);
      final notificationService = NotificationService();

      await repository.snoozeDose(
        medicationId: int.parse(dose.medicationId),
        scheduledDate: now,
        scheduledHour: hour24,
        scheduledMinute: minute,
        notes:
            'Snoozed for $minutes minutes until ${snoozeUntil.hour}:${snoozeUntil.minute.toString().padLeft(2, '0')}',
      );

      await notificationService.snoozeNotification(
        medicationId: int.parse(dose.medicationId),
        medicationName: dose.medicationName,
        dose: dose.dosage,
        minutes: minutes,
        scheduledHour: hour24,
        scheduledMinute: minute,
      );

      _updateDoseStatus(doseId, DoseStatus.snoozed);
    } catch (e) {
      debugPrint('Error snoozing dose: $e');
    }
  }

  /// Skip dose.
  Future<DoseResult> skipDose(String doseId) async {
    final dose = state.where((d) => d.id == doseId).firstOrNull;
    if (dose == null) return const DoseOperationFailed('Dose not found');
    final (:hour24, :minute) = _parseDoseTime(dose.time);

    try {
      final repository = ref.read(medicationRepositoryProvider);
      final result = await repository.skipDose(
        medicationId: int.parse(dose.medicationId),
        scheduledDate: DateTime.now(),
        scheduledHour: hour24,
        scheduledMinute: minute,
      );

      if (result is DoseRecorded || result is DoseAlreadyRecorded) {
        _updateDoseStatus(doseId, DoseStatus.skipped);
      } else {
        debugPrint('skipDose returned unexpected result: $result');
      }

      return result;
    } catch (e) {
      debugPrint('Error skipping dose: $e');
      return DoseOperationFailed(e.toString());
    }
  }

  /// Undo a dose action (revert to pending, restore stock if was taken).
  Future<void> undoDose(String doseId) async {
    final dose = state.where((d) => d.id == doseId).firstOrNull;
    if (dose == null) return;
    final (:hour24, :minute) = _parseDoseTime(dose.time);

    try {
      final repository = ref.read(medicationRepositoryProvider);
      await repository.undoDose(
        medicationId: int.parse(dose.medicationId),
        scheduledDate: DateTime.now(),
        scheduledHour: hour24,
        scheduledMinute: minute,
      );

      _updateDoseStatus(doseId, DoseStatus.pending);
      await refresh();
    } catch (e) {
      debugPrint('Error undoing dose: $e');
    }
  }

  /// Log a missed dose as taken now.
  Future<DoseResult> logMissedDose(String doseId) async {
    return markAsTaken(doseId);
  }

  /// Take all pending doses in the given list (e.g., a single timeline section).
  Future<void> takeAllPending(List<DoseEvent> doses) async {
    final pending = doses.where((d) => d.status == DoseStatus.pending).toList();
    for (final dose in pending) {
      await markAsTaken(dose.id);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _updateDoseStatus(String doseId, DoseStatus status) {
    state = [
      for (final d in state)
        if (d.id == doseId) d.copyWith(status: status) else d,
    ];
  }

  /// Parse a display-formatted time string ("8:00 AM") into 24-hour components.
  static ({int hour24, int minute}) _parseDoseTime(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = parts[1] == 'PM';

    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }

    return (hour24: hour, minute: minute);
  }
}

/// Provider for adherence summary
final adherenceSummaryProvider = FutureProvider<AdherenceSummary>((ref) async {
  final doses = ref.watch(todayDosesProvider);
  final database = ref.watch(appDatabaseProvider);

  final takenCount = doses.where((d) => d.status == DoseStatus.taken).length;
  final totalCount = doses.length;

  // Calculate actual streak from dose history using a single batch query
  var currentStreak = 0;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yearAgo = today.subtract(const Duration(days: 365));
  final allHistory = await database.getDoseHistoryBetween(yearAgo, now);

  if (allHistory.isNotEmpty) {
    // Group by date
    final dosesByDate = <DateTime, List<DoseHistoryData>>{};
    for (final dose in allHistory) {
      final dateKey = DateTime(
        dose.scheduledDate.year,
        dose.scheduledDate.month,
        dose.scheduledDate.day,
      );
      dosesByDate.putIfAbsent(dateKey, () => []).add(dose);
    }

    // Walk backwards from yesterday counting consecutive 100% days
    var checkDate = today.subtract(const Duration(days: 1));
    for (var i = 0; i < 365; i++) {
      final dayDoses = dosesByDate[checkDate];
      if (dayDoses == null || dayDoses.isEmpty) break;
      if (!dayDoses.every((h) => h.status == 'taken')) break;
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
  }

  // Count today if all taken so far
  if (totalCount > 0 && takenCount == totalCount) {
    currentStreak++;
  }

  return AdherenceSummary(
    takenToday: takenCount,
    totalToday: totalCount,
    currentStreak: currentStreak,
  );
});

/// Provider for grouped doses by time of day
final groupedDosesProvider = Provider<Map<String, List<DoseEvent>>>((ref) {
  final doses = ref.watch(todayDosesProvider);

  final grouped = <String, List<DoseEvent>>{
    'Morning': <DoseEvent>[],
    'Afternoon': <DoseEvent>[],
    'Evening': <DoseEvent>[],
    'Night': <DoseEvent>[],
  };

  for (final dose in doses) {
    final (:hour24, minute: _) = TodayDosesNotifier._parseDoseTime(dose.time);

    if (hour24 >= 6 && hour24 < 12) {
      grouped['Morning']!.add(dose);
    } else if (hour24 >= 12 && hour24 < 18) {
      grouped['Afternoon']!.add(dose);
    } else if (hour24 >= 18 && hour24 < 23) {
      grouped['Evening']!.add(dose);
    } else {
      grouped['Night']!.add(dose);
    }
  }

  return grouped;
});

/// Parse dose time string ("8:00 AM") into today's scheduled DateTime.
DateTime doseScheduledDateTime(String timeStr, DateTime now) {
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
  return DateTime(now.year, now.month, now.day, hour, minute);
}

/// Next upcoming pending dose today (sorted list first pending).
final nextDoseProvider = Provider<DoseEvent?>((ref) {
  final doses = ref.watch(todayDosesProvider);
  return doses.where((d) => d.status == DoseStatus.pending).firstOrNull;
});

/// Overdue doses: missed or snoozed, not yet taken/skipped.
final overdueDosesProvider = Provider<List<DoseEvent>>((ref) {
  final doses = ref.watch(todayDosesProvider);
  return doses
      .where(
        (d) => d.status == DoseStatus.missed || d.status == DoseStatus.snoozed,
      )
      .toList();
});

/// Pending doses excluding the next one (used in collapsible Later Today).
final laterTodayDosesProvider = Provider<List<DoseEvent>>((ref) {
  final doses = ref.watch(todayDosesProvider);
  final next = ref.watch(nextDoseProvider);
  return doses
      .where((d) => d.status == DoseStatus.pending && d.id != next?.id)
      .toList();
});

/// Provider for notification permission status
final notificationPermissionProvider =
    NotifierProvider<NotificationPermissionNotifier, bool>(
      NotificationPermissionNotifier.new,
    );

/// Notifier for notification permission status
class NotificationPermissionNotifier extends Notifier<bool> {
  @override
  bool build() {
    _checkPermission();
    return true; // Optimistic default; updated async
  }

  Future<void> _checkPermission() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    state = enabled;
  }

  void updatePermission(bool hasPermission) {
    state = hasPermission;
  }

  Future<void> refreshPermission() async {
    await _checkPermission();
  }
}
