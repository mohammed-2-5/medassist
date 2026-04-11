import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Stock quantity input with visual counter.
class StockQuantitySection extends ConsumerWidget {
  const StockQuantitySection({required this.formData, super.key});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.stockQuantity,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.howManyDoYouHave(formData.doseUnit),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: formData.stockQuantity > 0
                    ? formData.stockQuantity.toString()
                    : '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.quantityLabel,
                  hintText: '30',
                  prefixIcon: const Icon(Icons.inventory),
                  suffixText: formData.doseUnit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                ),
                onChanged: (value) {
                  final quantity = int.tryParse(value) ?? 0;
                  ref
                      .read(medicationFormProvider.notifier)
                      .setStockQuantity(quantity);
                },
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.medication,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formData.stockQuantity}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    l10n.inStock,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
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
