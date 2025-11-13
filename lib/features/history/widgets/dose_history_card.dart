import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';

/// Helper to convert scheduled date/hour/minute to DateTime
DateTime _getScheduledDateTime(DoseHistoryData dose) {
  return DateTime(
    dose.scheduledDate.year,
    dose.scheduledDate.month,
    dose.scheduledDate.day,
    dose.scheduledHour,
    dose.scheduledMinute,
  );
}

/// Card displaying dose history details
class DoseHistoryCard extends ConsumerWidget {

  const DoseHistoryCard({
    required this.dose,
    super.key,
  });
  final DoseHistoryData dose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final medicationAsync = ref.watch(medicationByIdProvider(dose.medicationId));

    return medicationAsync.when(
      data: (medication) {
        if (medication == null) {
          return const SizedBox.shrink();
        }

        final statusInfo = _getStatusInfo(dose.status, colorScheme);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with medication name and status
                Row(
                  children: [
                    // Status icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (statusInfo['color'] as Color).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusInfo['icon'] as IconData,
                        color: statusInfo['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Medication name and type
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

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (statusInfo['color'] as Color).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatStatus(dose.status),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusInfo['color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Dose details
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Dosage',
                        '${medication.dosePerTime} ${medication.doseUnit}',
                        Icons.medication,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Scheduled',
                        DateFormat('h:mm a').format(_getScheduledDateTime(dose)),
                        Icons.schedule,
                      ),
                    ),
                  ],
                ),

                if (dose.actualTime != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Taken at',
                          DateFormat('h:mm a').format(dose.actualTime!),
                          Icons.check_circle,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Delay',
                          _calculateDelay(dose),
                          Icons.timer,
                        ),
                      ),
                    ],
                  ),
                ],

                if (dose.notes != null && dose.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dose.notes!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, dynamic> _getStatusInfo(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'taken':
        return {
          'icon': Icons.check_circle,
          'color': colorScheme.secondary,
        };
      case 'missed':
        return {
          'icon': Icons.cancel,
          'color': colorScheme.error,
        };
      case 'skipped':
        return {
          'icon': Icons.block,
          'color': colorScheme.onSurfaceVariant,
        };
      case 'snoozed':
        return {
          'icon': Icons.snooze,
          'color': colorScheme.tertiary,
        };
      default: // pending
        return {
          'icon': Icons.schedule,
          'color': colorScheme.primary,
        };
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'taken':
        return 'Taken';
      case 'missed':
        return 'Missed';
      case 'skipped':
        return 'Skipped';
      case 'snoozed':
        return 'Snoozed';
      default:
        return 'Pending';
    }
  }

  String _calculateDelay(DoseHistoryData dose) {
    if (dose.actualTime == null) {
      return 'N/A';
    }

    final scheduledTime = _getScheduledDateTime(dose);
    final delay = dose.actualTime!.difference(scheduledTime);
    final minutes = delay.inMinutes.abs();

    if (minutes == 0) {
      return 'On time';
    } else if (delay.isNegative) {
      return '$minutes min early';
    } else if (minutes < 60) {
      return '$minutes min late';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m late';
    }
  }
}
