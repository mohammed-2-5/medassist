import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/home/models/dose_event.dart';
import 'package:med_assist/features/home/services/dose_event_generator.dart';
import 'package:med_assist/services/notification/notification_service.dart';

// Export database provider for backwards compatibility
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

/// Notifier for managing today's doses
class TodayDosesNotifier extends Notifier<List<DoseEvent>> {
  @override
  List<DoseEvent> build() {
    _loadTodayDoses();
    return [];
  }

  /// Load today's doses from database
  Future<void> _loadTodayDoses() async {
    try {
      // Get medications with reminders from database
      final medications =
          await ref.read(medicationsWithRemindersProvider.future);

      // Generate dose events for today
      final generator = ref.read(doseEventGeneratorProvider);
      final doseEvents = generator.generateTodayDoses(medications);

      // Load dose history for today to update statuses
      final database = ref.read(appDatabaseProvider);
      final today = DateTime.now();
      final history = await database.getDoseHistoryForDate(today);

      // Update dose statuses based on history
      final updatedDoses = doseEvents.map((dose) {
        // Find matching history record
        final parts = dose.time.split(' ');
        final timeParts = parts[0].split(':');
        final hour = int.parse(timeParts[0]);
        final isPM = parts[1] == 'PM';
        final hour24 = isPM && hour != 12
            ? hour + 12
            : !isPM && hour == 12
                ? 0
                : hour;
        final minute = int.parse(timeParts[1]);

        final historyRecord = history.cast<DoseHistoryData?>().firstWhere(
              (h) =>
                  h != null &&
                  h.medicationId.toString() == dose.medicationId &&
                  h.scheduledHour == hour24 &&
                  h.scheduledMinute == minute,
              orElse: () => null,
            );

        if (historyRecord != null) {
          // Update status from history
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
      // Log error but don't crash
      state = [];
    }
  }

  /// Refresh doses from database
  Future<void> refresh() async {
    await _loadTodayDoses();
  }

  /// Mark dose as taken
  Future<void> markAsTaken(String doseId) async {
    final dose = state.firstWhere((d) => d.id == doseId);

    // Parse time
    final parts = dose.time.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final isPM = parts[1] == 'PM';
    final hour24 = isPM && hour != 12 ? hour + 12 : !isPM && hour == 12 ? 0 : hour;
    final minute = int.parse(timeParts[1]);

    try {
      final database = ref.read(appDatabaseProvider);
      final repository = ref.read(medicationRepositoryProvider);

      // Record in history
      await database.recordDoseTaken(
        medicationId: int.parse(dose.medicationId),
        scheduledDate: DateTime.now(),
        scheduledHour: hour24,
        scheduledMinute: minute,
      );

      // Decrease stock
      final medication = await database.getMedicationById(int.parse(dose.medicationId));
      if (medication != null) {
        final newStock = (medication.stockQuantity - medication.dosePerTime).round();
        await repository.updateStockQuantity(
          int.parse(dose.medicationId),
          newStock >= 0 ? newStock : 0,
        );
      }

      // Update UI
      state = [
        for (final d in state)
          if (d.id == doseId)
            d.copyWith(status: DoseStatus.taken)
          else
            d
      ];

      // Refresh to update stock count
      await refresh();
    } catch (e) {
      // Handle error
    }
  }

  /// Snooze dose with specified duration
  Future<void> snoozeDose(String doseId, {int minutes = 15}) async {
    final dose = state.firstWhere((d) => d.id == doseId);

    // Parse time
    final parts = dose.time.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final isPM = parts[1] == 'PM';
    final hour24 = isPM && hour != 12 ? hour + 12 : !isPM && hour == 12 ? 0 : hour;
    final minute = int.parse(timeParts[1]);

    try {
      final database = ref.read(appDatabaseProvider);
      final notificationService = NotificationService();
      final now = DateTime.now();
      final snoozeUntil = now.add(Duration(minutes: minutes));

      // Record in history as snoozed
      await database.recordDoseSnoozed(
        medicationId: int.parse(dose.medicationId),
        scheduledDate: now,
        scheduledHour: hour24,
        scheduledMinute: minute,
        notes: 'Snoozed for $minutes minutes until ${snoozeUntil.hour}:${snoozeUntil.minute.toString().padLeft(2, '0')}',
      );

      // Schedule snooze notification
      await notificationService.snoozeNotification(
        medicationId: int.parse(dose.medicationId),
        medicationName: dose.medicationName,
        dose: dose.dosage,
        minutes: minutes,
      );

      // Update UI
      state = [
        for (final d in state)
          if (d.id == doseId)
            d.copyWith(status: DoseStatus.snoozed)
          else
            d
      ];
    } catch (e) {
      // Handle error
    }
  }

  /// Skip dose
  Future<void> skipDose(String doseId) async {
    final dose = state.firstWhere((d) => d.id == doseId);

    // Parse time
    final parts = dose.time.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final isPM = parts[1] == 'PM';
    final hour24 = isPM && hour != 12 ? hour + 12 : !isPM && hour == 12 ? 0 : hour;
    final minute = int.parse(timeParts[1]);

    try {
      final database = ref.read(appDatabaseProvider);

      // Record in history as skipped
      await database.recordDoseSkipped(
        medicationId: int.parse(dose.medicationId),
        scheduledDate: DateTime.now(),
        scheduledHour: hour24,
        scheduledMinute: minute,
      );

      // Update UI
      state = [
        for (final d in state)
          if (d.id == doseId)
            d.copyWith(status: DoseStatus.skipped)
          else
            d
      ];
    } catch (e) {
      // Handle error
    }
  }

  /// Undo action (revert to pending)
  Future<void> undoDose(String doseId) async {
    final dose = state.firstWhere((d) => d.id == doseId);

    // Parse time
    final parts = dose.time.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final isPM = parts[1] == 'PM';
    final hour24 = isPM && hour != 12 ? hour + 12 : !isPM && hour == 12 ? 0 : hour;
    final minute = int.parse(timeParts[1]);

    try {
      final database = ref.read(appDatabaseProvider);
      final repository = ref.read(medicationRepositoryProvider);

      // Find the existing dose record
      final existingRecord = await database.findDoseRecord(
        medicationId: int.parse(dose.medicationId),
        scheduledDate: DateTime.now(),
        scheduledHour: hour24,
        scheduledMinute: minute,
      );

      if (existingRecord != null) {
        // If it was taken, restore the stock
        if (existingRecord.status == 'taken') {
          final medication = await database.getMedicationById(int.parse(dose.medicationId));
          if (medication != null) {
            final restoredStock = (medication.stockQuantity + medication.dosePerTime).round();
            await repository.updateStockQuantity(
              int.parse(dose.medicationId),
              restoredStock,
            );
          }
        }

        // Delete the dose history record
        await database.deleteDoseRecord(
          medicationId: int.parse(dose.medicationId),
          scheduledDate: DateTime.now(),
          scheduledHour: hour24,
          scheduledMinute: minute,
        );
      }

      // Update UI
      state = [
        for (final d in state)
          if (d.id == doseId)
            d.copyWith(status: DoseStatus.pending)
          else
            d
      ];

      // Refresh to update stock count
      await refresh();
    } catch (e) {
      // Handle error
    }
  }

  /// Log missed dose as taken now
  Future<void> logMissedDose(String doseId) async {
    final dose = state.firstWhere((d) => d.id == doseId);

    // Parse time
    final parts = dose.time.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final isPM = parts[1] == 'PM';
    final hour24 = isPM && hour != 12 ? hour + 12 : !isPM && hour == 12 ? 0 : hour;
    final minute = int.parse(timeParts[1]);

    try {
      final database = ref.read(appDatabaseProvider);
      final repository = ref.read(medicationRepositoryProvider);

      // Record in history as taken (with current time as actual time)
      await database.recordDoseTaken(
        medicationId: int.parse(dose.medicationId),
        scheduledDate: DateTime.now(),
        scheduledHour: hour24,
        scheduledMinute: minute,
      );

      // Decrease stock
      final medication = await database.getMedicationById(int.parse(dose.medicationId));
      if (medication != null) {
        final newStock = (medication.stockQuantity - medication.dosePerTime).round();
        await repository.updateStockQuantity(
          int.parse(dose.medicationId),
          newStock >= 0 ? newStock : 0,
        );
      }

      // Update UI
      state = [
        for (final d in state)
          if (d.id == doseId)
            d.copyWith(status: DoseStatus.taken)
          else
            d
      ];

      // Refresh to update stock count
      await refresh();
    } catch (e) {
      // Handle error
    }
  }
}

/// Provider for adherence summary
final adherenceSummaryProvider = Provider<AdherenceSummary>((ref) {
  final doses = ref.watch(todayDosesProvider);

  final takenCount = doses.where((d) => d.status == DoseStatus.taken).length;
  final totalCount = doses.length;

  // TODO(dev): Get actual streak from database
  const currentStreak = 4;

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
    final hour = int.tryParse(dose.time.split(':')[0]) ?? 0;

    if (hour >= 6 && hour < 12) {
      grouped['Morning']!.add(dose);
    } else if (hour >= 12 && hour < 18) {
      grouped['Afternoon']!.add(dose);
    } else if (hour >= 18 && hour < 23) {
      grouped['Evening']!.add(dose);
    } else {
      grouped['Night']!.add(dose);
    }
  }

  return grouped;
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
    // TODO(dev): Check actual permission status
    return true;
  }

  /// Update permission status
  void updatePermission(bool hasPermission) {
    state = hasPermission;
  }
}
