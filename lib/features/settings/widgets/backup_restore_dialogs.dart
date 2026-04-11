import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/backup/backup_import_result.dart';

Future<bool?> showRestoreConfirmationDialog(
  BuildContext context,
  AppLocalizations l10n,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.restoreFromBackupQuestion),
      content: Text(l10n.restoreConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n.restore),
        ),
      ],
    ),
  );
}

Future<void> showRestoreCompleteDialog(
  BuildContext context,
  AppLocalizations l10n,
  BackupImportResult result,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(l10n.restoreComplete),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.successfullyRestoredItems(result.totalImported)),
            const SizedBox(height: 12),
            _RestoreStatRow(
              label: 'Medications',
              count: result.medicationsImported,
            ),
            _RestoreStatRow(
              label: 'Dose History',
              count: result.doseHistoryImported,
            ),
            _RestoreStatRow(
              label: 'Snooze History',
              count: result.snoozeHistoryImported,
            ),
            _RestoreStatRow(
              label: 'Stock History',
              count: result.stockHistoryImported,
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.ok),
        ),
      ],
    ),
  );
}

class _RestoreStatRow extends StatelessWidget {
  const _RestoreStatRow({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
