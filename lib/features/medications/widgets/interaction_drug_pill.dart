import 'package:flutter/material.dart';

/// Pill-shaped widget showing a single drug name inside an interaction card.
class InteractionDrugPill extends StatelessWidget {
  const InteractionDrugPill({
    required this.name,
    required this.color,
    super.key,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.medication_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
