import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// Shared action handlers for medication screens.
class MedicationActions {
  const MedicationActions._();

  /// Toggle medication active/paused state.
  ///
  /// [popOnComplete] pops the screen after toggling (detail screen).
  /// [onRefresh] optional callback after successful toggle.
  static Future<void> toggleActive({
    required BuildContext context,
    required WidgetRef ref,
    required Medication medication,
    VoidCallback? onRefresh,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    HapticService.medium();

    try {
      final database = ref.read(appDatabaseProvider);
      final notificationService = NotificationService();
      final updated = medication.copyWith(isActive: !medication.isActive);
      await database.updateMedication(updated);

      if (medication.isActive) {
        await notificationService.cancelMedicationReminders(medication.id);
      } else {
        final reminderTimes =
            await database.getReminderTimes(medication.id);
        await notificationService.scheduleRemindersForMedication(
          updated,
          reminderTimes,
        );
      }

      if (context.mounted) {
        HapticService.success();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              medication.isActive
                  ? l10n.medicationPaused
                  : l10n.medicationResumed,
            ),
          ),
        );
        onRefresh?.call();
        ProviderRefreshUtils.refreshMedicationDetail(ref, medication.id);
        ProviderRefreshUtils.refreshAllMedicationProviders(ref);
      }
    } catch (e) {
      if (context.mounted) {
        HapticService.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Delete a medication with confirmation dialog.
  ///
  /// [popOnComplete] pops the screen after deletion (detail screen).
  static Future<void> delete({
    required BuildContext context,
    required WidgetRef ref,
    required int medicationId,
    bool popOnComplete = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    HapticService.warning();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteMedicationQuestion),
        content: Text(l10n.deleteMedicationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      try {
        final repository = ref.read(medicationRepositoryProvider);
        await repository.deleteMedication(medicationId);
        if (context.mounted) {
          HapticService.success();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.medicationDeleted),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          ProviderRefreshUtils.refreshAllMedicationProviders(ref);
          if (popOnComplete) context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          HapticService.error();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorDeletingMedication(e.toString())),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
