import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class DurationSection extends ConsumerWidget {
  const DurationSection({super.key, required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.treatmentDuration,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: formData.durationDays.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.durationDays,
                  hintText: '7',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixText: AppLocalizations.of(context)!.days,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                ),
                onChanged: (value) {
                  final days = int.tryParse(value) ?? 7;
                  ref
                      .read(medicationFormProvider.notifier)
                      .setDurationDays(days);
                },
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    color: colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formData.durationDays}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.days,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
