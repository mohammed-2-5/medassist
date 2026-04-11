import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class DosePerTimeSection extends ConsumerWidget {
  const DosePerTimeSection({super.key, required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.dosePerTime,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: formData.dosePerTime.toString(),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amount,
                  hintText: '1.0',
                  prefixIcon: const Icon(Icons.medication),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                ),
                onChanged: (value) {
                  final dose = double.tryParse(value) ?? 1.0;
                  ref.read(medicationFormProvider.notifier).setDosePerTime(dose);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: formData.doseUnit,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: const [
                  DropdownMenuItem(value: 'tablet', child: Text('tablet')),
                  DropdownMenuItem(value: 'capsule', child: Text('capsule')),
                  DropdownMenuItem(value: 'ml', child: Text('ml')),
                  DropdownMenuItem(value: 'mg', child: Text('mg')),
                  DropdownMenuItem(value: 'drop', child: Text('drop')),
                  DropdownMenuItem(value: 'puff', child: Text('puff')),
                  DropdownMenuItem(value: 'unit', child: Text('unit')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(medicationFormProvider.notifier).setDoseUnit(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
