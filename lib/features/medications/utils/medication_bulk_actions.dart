import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';

/// Helper class for medication bulk actions
///
/// Handles:
/// - Bulk delete
/// - Bulk pause
/// - Bulk resume
/// - Confirmation dialogs
/// - Error handling
class MedicationBulkActions {
  const MedicationBulkActions({
    required this.context,
    required this.ref,
    required this.selectedIds,
    required this.medications,
    required this.onComplete,
  });

  final BuildContext context;
  final WidgetRef ref;
  final Set<int> selectedIds;
  final List<Medication> medications;
  final VoidCallback onComplete;

  /// Delete selected medications
  Future<void> delete() async {
    final l10n = AppLocalizations.of(context)!;
    HapticService.warning();

    final confirmed = await _showConfirmDialog(
      title: l10n.deleteMedicationQuestion,
      message: l10n.deleteMedicationConfirm,
      confirmText: l10n.delete,
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(medicationRepositoryProvider);
        for (final id in selectedIds) {
          await repository.deleteMedication(id);
        }

        if (context.mounted) {
          HapticService.success();
          _showSuccessSnackBar('${selectedIds.length} ${l10n.medicationsDeleted ?? 'medication(s) deleted'}');
        }

        onComplete();
        ProviderRefreshUtils.refreshAllMedicationProviders(ref);
      } catch (e) {
        if (context.mounted) {
          HapticService.error();
          _showErrorSnackBar(l10n.errorDeletingMedication(e.toString()));
        }
      }
    }
  }

  /// Pause selected medications
  Future<void> pause() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final database = ref.read(appDatabaseProvider);

      for (final id in selectedIds) {
        final med = medications.firstWhere((m) => m.id == id);
        final updated = med.copyWith(isActive: false);
        await database.updateMedication(updated);
      }

      if (context.mounted) {
        _showSuccessSnackBar('${selectedIds.length} ${l10n.medicationsPaused ?? 'medication(s) paused'}');
      }

      onComplete();
      ProviderRefreshUtils.refreshAllMedicationProviders(ref);
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(l10n.errorMessage(e.toString()));
      }
    }
  }

  /// Resume selected medications
  Future<void> resume() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final database = ref.read(appDatabaseProvider);

      for (final id in selectedIds) {
        final med = medications.firstWhere((m) => m.id == id);
        final updated = med.copyWith(isActive: true);
        await database.updateMedication(updated);
      }

      if (context.mounted) {
        _showSuccessSnackBar('${selectedIds.length} ${l10n.medicationsResumed ?? 'medication(s) resumed'}');
      }

      onComplete();
      ProviderRefreshUtils.refreshAllMedicationProviders(ref);
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(l10n.errorMessage(e.toString()));
      }
    }
  }

  // Helper methods

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.light();
              Navigator.pop(context, false);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              HapticService.delete();
              Navigator.pop(context, true);
            },
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
