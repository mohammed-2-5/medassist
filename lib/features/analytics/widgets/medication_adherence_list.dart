import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';

/// Widget displaying adherence statistics for each medication
class MedicationAdherenceList extends StatelessWidget {

  const MedicationAdherenceList({
    required this.medicationAnalytics,
    super.key,
  });
  final List<Map<String, dynamic>> medicationAnalytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (medicationAnalytics.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.medication,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No medication data',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start taking your medications to see analytics',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: medicationAnalytics.map((data) {
        final medication = data['medication'] as Medication;
        final adherence = data['adherence'] as int;
        final total = data['total'] as int;
        final taken = data['taken'] as int;
        final missed = data['missed'] as int;

        final adherenceColor = _getAdherenceColor(adherence, colorScheme);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with medication name and adherence percentage
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.medicineName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            medication.medicineType,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: adherenceColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$adherence%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: adherenceColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: adherence / 100,
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(adherenceColor),
                  ),
                ),

                const SizedBox(height: 12),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      context,
                      'Total',
                      total.toString(),
                      Icons.medication,
                      colorScheme.primary,
                    ),
                    _buildStatColumn(
                      context,
                      'Taken',
                      taken.toString(),
                      Icons.check_circle,
                      colorScheme.secondary,
                    ),
                    _buildStatColumn(
                      context,
                      'Missed',
                      missed.toString(),
                      Icons.cancel,
                      colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getAdherenceColor(int rate, ColorScheme colorScheme) {
    if (rate >= 90) {
      return colorScheme.secondary; // Green
    } else if (rate >= 70) {
      return colorScheme.tertiary; // Orange/Yellow
    } else {
      return colorScheme.error; // Red
    }
  }
}
