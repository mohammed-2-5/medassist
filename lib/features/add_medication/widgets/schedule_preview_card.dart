import 'package:flutter/material.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class SchedulePreviewCard extends StatelessWidget {
  const SchedulePreviewCard({super.key, required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isValid = formData.isStep2Valid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isValid ? colorScheme.secondary : colorScheme.outline,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.info,
                color: isValid
                    ? colorScheme.secondary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isValid
                      ? AppLocalizations.of(context)!.scheduleSummary
                      : AppLocalizations.of(context)!.completeTheForm,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isValid
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (isValid) ...[
            const SizedBox(height: 16),
            _SummaryRow(
              icon: Icons.schedule,
              label: AppLocalizations.of(context)!.frequency,
              value: AppLocalizations.of(
                context,
              )!.xTimesPerDay(formData.timesPerDay),
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.medication,
              label: AppLocalizations.of(context)!.eachDose,
              value: '${formData.dosePerTime} ${formData.doseUnit}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.event,
              label: AppLocalizations.of(context)!.duration,
              value:
                  '${formData.durationDays} ${AppLocalizations.of(context)!.days}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.calendar_today,
              label: AppLocalizations.of(context)!.starts,
              value: _formatDate(formData.startDate ?? DateTime.now()),
            ),
          ],
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSecondaryContainer),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSecondaryContainer.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
