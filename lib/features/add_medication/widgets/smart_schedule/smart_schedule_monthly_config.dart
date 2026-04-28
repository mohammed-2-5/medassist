import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/widgets/smart_schedule/smart_schedule_stepper.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Monthly sub-config: day-of-month + every-N-months stepper.
class SmartScheduleMonthlyConfig extends ConsumerWidget {
  const SmartScheduleMonthlyConfig({required this.formData, super.key});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final day = formData.dayOfMonth ?? formData.startDate?.day ?? 1;
    final months = formData.intervalMonths ?? 1;

    void apply({int? d, int? m}) {
      ref
          .read(medicationFormProvider.notifier)
          .applySmartSchedule(
            pattern: RepetitionPattern.monthly,
            dayOfMonth: d ?? day,
            intervalMonths: m ?? months,
          );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.dayOfMonthLabel, style: theme.textTheme.bodyMedium),
            const SizedBox(width: 12),
            SmartScheduleStepper(
              value: day,
              min: 1,
              max: 31,
              onChanged: (v) => apply(d: v),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(l10n.everyLabel, style: theme.textTheme.bodyMedium),
            const SizedBox(width: 12),
            SmartScheduleStepper(
              value: months,
              min: 1,
              max: 12,
              onChanged: (v) => apply(m: v),
            ),
            const SizedBox(width: 8),
            Text(
              months == 1 ? l10n.monthSingular : l10n.monthPlural,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (day >= 29)
          Text(
            l10n.monthlyShortMonthHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}
