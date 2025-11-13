import 'package:flutter/material.dart';
import 'package:med_assist/features/home/models/dose_event.dart';

/// Dose card header with medication info and time badge
class DoseCardHeader extends StatelessWidget {

  const DoseCardHeader({
    required this.dose,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.textColor,
    required this.timeBadgeColor,
    required this.timeBadgeTextColor,
    super.key,
  });
  final DoseEvent dose;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color textColor;
  final Color timeBadgeColor;
  final Color timeBadgeTextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Medication icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.medication_rounded,
            color: iconColor,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        // Medication details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dose.medicationName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dose.dosage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // Time badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: timeBadgeColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: timeBadgeTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                dose.time,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: timeBadgeTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
