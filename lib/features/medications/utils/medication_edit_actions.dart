import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/features/add_medication/providers/current_step_provider.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Static action handlers for the medication edit/add wizard.
class MedicationEditActions {
  const MedicationEditActions._();

  static Future<void> save({
    required BuildContext context,
    required WidgetRef ref,
    required int medicationId,
  }) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await ref
          .read(medicationFormProvider.notifier)
          .saveMedication();
      if (!context.mounted) return;
      context.pop(); // close loading

      if (success) {
        ProviderRefreshUtils.refreshMedicationDetail(ref, medicationId);
        ref.read(currentStepProvider.notifier).reset();
        ref.read(medicationFormProvider.notifier).reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.medicationUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToUpdateMedication),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      context.pop(); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
