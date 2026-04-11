import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/widgets/meal_timing_selector.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class ReminderTimesSection extends ConsumerWidget {
  const ReminderTimesSection({super.key, required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.reminderTimesTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (formData.reminderTimes.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  ref
                      .read(medicationFormProvider.notifier)
                      .generateDefaultReminderTimes();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.reset),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (formData.reminderTimes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.selectTimesForReminders,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          Column(
            children: List.generate(
              formData.reminderTimes.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ReminderTimeCard(
                  index: index,
                  reminderData: formData.reminderTimes[index],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReminderTimeCard extends ConsumerWidget {
  const _ReminderTimeCard({
    required this.index,
    required this.reminderData,
  });

  final int index;
  final ReminderTimeData reminderData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _selectReminderTime(context, ref),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.alarm,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dose(index + 1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(reminderData.time),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit, color: colorScheme.primary, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          MealTimingSelector(
            selectedTiming: reminderData.mealTiming,
            onChanged: (timing) {
              ref
                  .read(medicationFormProvider.notifier)
                  .updateReminderMealTiming(index, timing);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectReminderTime(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderData.time,
    );

    if (picked != null) {
      ref.read(medicationFormProvider.notifier).updateReminderTime(index, picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
