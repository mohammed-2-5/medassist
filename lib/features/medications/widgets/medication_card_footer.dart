import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MedicationCardFooter extends StatelessWidget {
  const MedicationCardFooter({
    required this.isActive,
    required this.onEdit,
    required this.onToggleActive,
    super.key,
  });

  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 16),
            label: Text(l10n.edit),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onToggleActive,
            icon: Icon(isActive ? Icons.pause : Icons.play_arrow, size: 16),
            label: Text(isActive ? l10n.pause : l10n.resume),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
