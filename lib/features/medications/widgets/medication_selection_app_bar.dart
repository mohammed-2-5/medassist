import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Selection Mode AppBar
///
/// Shows when medications are being selected for bulk actions.
/// Displays count and provides "Select All" action.
class MedicationSelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MedicationSelectionAppBar({
    required this.selectedCount,
    required this.onClose,
    required this.onSelectAll,
    super.key,
  });

  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClose,
      ),
      title: Text('$selectedCount ${l10n.selected ?? 'selected'}'),
      actions: [
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: l10n.selectAll ?? 'Select all',
          onPressed: onSelectAll,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
