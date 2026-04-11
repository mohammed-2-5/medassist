import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class RepetitionPatternSection extends ConsumerWidget {
  const RepetitionPatternSection({super.key, required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.repetitionPatternTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.whenToTakeMedication,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RepetitionPattern.values.map((pattern) {
            final isSelected = formData.repetitionPattern == pattern;
            return _PatternChip(
              pattern: pattern,
              isSelected: isSelected,
              onTap: () {
                ref
                    .read(medicationFormProvider.notifier)
                    .setRepetitionPattern(pattern);
              },
            );
          }).toList(),
        ),
        if (formData.repetitionPattern == RepetitionPattern.specificDays) ...[
          const SizedBox(height: 16),
          _WeekdaySelector(formData: formData),
        ],
        if (formData.repetitionPattern != RepetitionPattern.asNeeded &&
            formData.specificDaysOfWeek.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ActiveDaysPreview(formData: formData),
        ],
      ],
    );
  }
}

class _PatternChip extends StatelessWidget {
  const _PatternChip({
    required this.pattern,
    required this.isSelected,
    required this.onTap,
  });

  final RepetitionPattern pattern;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pattern.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pattern.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdaySelector extends ConsumerWidget {
  const _WeekdaySelector({required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.selectDaysOfWeek,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isSelected =
                formData.specificDaysOfWeek.contains(dayNumber);
            final dayName = RepetitionPattern.getWeekdayName(dayNumber);

            return InkWell(
              onTap: () {
                final newDays = List<int>.from(formData.specificDaysOfWeek);
                if (isSelected) {
                  newDays.remove(dayNumber);
                } else {
                  newDays.add(dayNumber);
                }
                newDays.sort();
                ref
                    .read(medicationFormProvider.notifier)
                    .setSpecificDaysOfWeek(newDays);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  dayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ActiveDaysPreview extends StatelessWidget {
  const _ActiveDaysPreview({required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!
                  .activeOnDays(_getActiveDaysText(context)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getActiveDaysText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (formData.repetitionPattern == RepetitionPattern.daily) {
      return l10n.everyDay;
    } else if (formData.repetitionPattern == RepetitionPattern.everyOtherDay) {
      return l10n.everyOtherDay;
    } else if (formData.repetitionPattern == RepetitionPattern.weekdays) {
      return l10n.mondayToFriday;
    } else if (formData.repetitionPattern == RepetitionPattern.weekends) {
      return l10n.saturdayAndSunday;
    } else if (formData.specificDaysOfWeek.isEmpty) {
      return l10n.noDaysSelected;
    } else {
      return formData.specificDaysOfWeek
          .map(RepetitionPattern.getWeekdayName)
          .join(', ');
    }
  }
}
