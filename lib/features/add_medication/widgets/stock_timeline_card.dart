import 'package:flutter/material.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Visual timeline showing daily usage, days remaining, alerts, and run-out date.
class StockTimelineCard extends StatelessWidget {
  const StockTimelineCard({required this.formData, super.key});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final runOutDate = formData.stockRunOutDate;
    final lowStockDate = formData.lowStockReminderDate;
    final dailyUsage = formData.dosePerTime * formData.timesPerDay;
    final daysRemaining = runOutDate != null
        ? runOutDate.difference(DateTime.now()).inDays
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.stockTimeline,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TimelineItem(
            icon: Icons.today,
            label: l10n.dailyUsageLabel,
            value:
                '$dailyUsage ${formData.doseUnit}${dailyUsage != 1 ? 's' : ''}',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          _TimelineItem(
            icon: Icons.event_available,
            label: l10n.stockLastsFor,
            value: '$daysRemaining day${daysRemaining != 1 ? 's' : ''}',
            color: daysRemaining > 7
                ? Colors.green
                : daysRemaining > 3
                ? Colors.orange
                : Colors.red,
          ),
          if (lowStockDate != null && formData.remindBeforeRunOut) ...[
            const SizedBox(height: 16),
            _TimelineItem(
              icon: Icons.notifications_active,
              label: l10n.lowStockAlert,
              value: _formatDate(lowStockDate),
              color: Colors.orange,
            ),
          ],
          if (runOutDate != null) ...[
            const SizedBox(height: 16),
            _TimelineItem(
              icon: Icons.warning,
              label: l10n.stockRunsOut,
              value: _formatDate(runOutDate),
              color: Colors.red,
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _StockProgressBar(daysRemaining: daysRemaining),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StockProgressBar extends StatelessWidget {
  const _StockProgressBar({required this.daysRemaining});

  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final percentage = daysRemaining > 0 ? 1.0 : 0.0;
    final color = daysRemaining > 7
        ? Colors.green
        : daysRemaining > 3
        ? Colors.orange
        : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.stockLevelLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: colorScheme.surface.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
