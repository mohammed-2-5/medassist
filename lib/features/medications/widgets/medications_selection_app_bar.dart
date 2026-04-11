import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// AppBar shown when the medications list is in bulk-selection mode.
class MedicationsSelectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const MedicationsSelectionAppBar({
    required this.selectedCount,
    required this.onClose,
    required this.onSelectAll,
    super.key,
  });

  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onSelectAll;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClose,
      ),
      // ignore: prefer_if_null_operators
      title: Text('$selectedCount ${l10n.selected ?? 'selected'}'),
      actions: [
        IconButton(
          icon: const Icon(Icons.select_all),
          // ignore: prefer_if_null_operators
          tooltip: l10n.selectAll ?? 'Select all',
          onPressed: onSelectAll,
        ),
      ],
    );
  }
}
