import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/widgets/smart_schedule/smart_schedule_stepper.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Weekly sub-config: weekday chips + every-N-weeks stepper + presets.
class SmartScheduleWeeklyConfig extends ConsumerWidget {
  const SmartScheduleWeeklyConfig({required this.formData, super.key});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final selectedDays = formData.specificDaysOfWeek;
    final intervalWeeks = formData.intervalWeeks ?? 1;

    void apply(List<int> days, int weeks) {
      ref
          .read(medicationFormProvider.notifier)
          .applySmartSchedule(
            pattern: RepetitionPattern.weekly,
            specificDaysOfWeek: days,
            intervalWeeks: weeks,
          );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _PresetChip(
              label: l10n.weekdaysPreset,
              onTap: () => apply([1, 2, 3, 4, 5], intervalWeeks),
            ),
            _PresetChip(
              label: l10n.weekendsPreset,
              onTap: () => apply([6, 7], intervalWeeks),
            ),
            _PresetChip(
              label: l10n.allDaysPreset,
              onTap: () => apply([1, 2, 3, 4, 5, 6, 7], intervalWeeks),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final day = i + 1;
            final isSelected = selectedDays.contains(day);
            return InkWell(
              onTap: () {
                final newDays = List<int>.from(selectedDays);
                if (isSelected) {
                  newDays.remove(day);
                } else {
                  newDays.add(day);
                }
                newDays.sort();
                apply(newDays, intervalWeeks);
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? cs.primary
                        : cs.outlineVariant.withOpacity(0.4),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  RepetitionPattern.getWeekdayName(day),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? cs.onPrimary : cs.onSurface,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(l10n.everyLabel, style: theme.textTheme.bodyMedium),
            const SizedBox(width: 12),
            SmartScheduleStepper(
              value: intervalWeeks,
              min: 1,
              max: 12,
              onChanged: (v) => apply(selectedDays, v),
            ),
            const SizedBox(width: 8),
            Text(
              intervalWeeks == 1 ? l10n.weekSingular : l10n.weekPlural,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ActionChip(
      label: Text(label, style: theme.textTheme.bodySmall),
      onPressed: onTap,
      backgroundColor: cs.secondaryContainer.withOpacity(0.4),
      side: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
    );
  }
}
