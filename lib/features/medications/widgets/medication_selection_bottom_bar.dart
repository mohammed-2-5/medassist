import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Selection Mode Bottom Bar
///
/// Provides bulk action buttons:
/// - Delete
/// - Pause
/// - Resume
class MedicationSelectionBottomBar extends StatelessWidget {
  const MedicationSelectionBottomBar({
    required this.hasSelection,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onDelete;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: hasSelection ? onDelete : null,
            icon: const Icon(Icons.delete),
            label: Text(l10n.delete),
          ),
          TextButton.icon(
            onPressed: hasSelection ? onPause : null,
            icon: const Icon(Icons.pause),
            label: Text(l10n.pause),
          ),
          TextButton.icon(
            onPressed: hasSelection ? onResume : null,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.resume),
          ),
        ],
      ),
    );
  }
}
