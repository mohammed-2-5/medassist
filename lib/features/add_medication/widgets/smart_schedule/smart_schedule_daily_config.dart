import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/widgets/smart_schedule/smart_schedule_stepper.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Daily sub-config: "Every day" vs "Every N days".
class SmartScheduleDailyConfig extends ConsumerWidget {
  const SmartScheduleDailyConfig({required this.formData, super.key});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isEveryN = formData.repetitionPattern == RepetitionPattern.everyNDays;
    final n = formData.intervalDays ?? 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _OptionPill(
                label: l10n.everyDay,
                selected: !isEveryN,
                onTap: () => ref
                    .read(medicationFormProvider.notifier)
                    .applySmartSchedule(pattern: RepetitionPattern.daily),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _OptionPill(
                label: l10n.everyNDays,
                selected: isEveryN,
                onTap: () => ref
                    .read(medicationFormProvider.notifier)
                    .applySmartSchedule(
                      pattern: RepetitionPattern.everyNDays,
                      intervalDays: n,
                    ),
              ),
            ),
          ],
        ),
        if (isEveryN) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Text(l10n.everyLabel, style: theme.textTheme.bodyMedium),
              const SizedBox(width: 12),
              SmartScheduleStepper(
                value: n,
                min: 2,
                max: 30,
                onChanged: (v) => ref
                    .read(medicationFormProvider.notifier)
                    .applySmartSchedule(
                      pattern: RepetitionPattern.everyNDays,
                      intervalDays: v,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.daysUnit,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _OptionPill extends StatelessWidget {
  const _OptionPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? cs.onPrimaryContainer : cs.onSurface,
          ),
        ),
      ),
    );
  }
}
