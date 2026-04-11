import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/medications/providers/medications_filter_provider.dart';
import 'package:med_assist/features/medications/utils/medication_bulk_actions.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Bottom bar that exposes delete / pause / resume bulk actions.
///
/// Reads the current filtered medications list internally so the parent
/// does not need to pass it down.
class MedicationsBulkActionBar extends ConsumerWidget {
  const MedicationsBulkActionBar({
    required this.selectedIds,
    required this.onExit,
    super.key,
  });

  final Set<int> selectedIds;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isEmpty = selectedIds.isEmpty;

    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: isEmpty ? null : () => _run(context, ref, (a) => a.delete()),
            icon: const Icon(Icons.delete),
            label: Text(l10n.delete),
          ),
          TextButton.icon(
            onPressed: isEmpty ? null : () => _run(context, ref, (a) => a.pause()),
            icon: const Icon(Icons.pause),
            label: Text(l10n.pause),
          ),
          TextButton.icon(
            onPressed: isEmpty ? null : () => _run(context, ref, (a) => a.resume()),
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.resume),
          ),
        ],
      ),
    );
  }

  void _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(MedicationBulkActions) action,
  ) {
    final medications =
        ref.read(filteredMedicationsProvider).value ?? <Medication>[];
    action(
      MedicationBulkActions(
        context: context,
        ref: ref,
        selectedIds: selectedIds,
        medications: medications,
        onComplete: onExit,
      ),
    );
  }
}
