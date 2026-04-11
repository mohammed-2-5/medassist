import 'package:flutter/material.dart';

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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
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
            label: Text(isActive ? 'Pause' : 'Resume'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
