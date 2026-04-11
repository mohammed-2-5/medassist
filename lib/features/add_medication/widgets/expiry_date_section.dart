import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Expiry date picker with days-before reminder chips.
class ExpiryDateSection extends ConsumerWidget {
  const ExpiryDateSection({required this.formData, super.key});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_busy, color: colorScheme.error, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.expiryDateOptional,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.trackWhenExpires,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _ExpiryDatePicker(formData: formData),
          if (formData.expiryDate != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              l10n.remindMeBeforeExpiry,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _ExpiryReminderChips(formData: formData),
          ],
        ],
      ),
    );
  }
}

class _ExpiryDatePicker extends ConsumerWidget {
  const _ExpiryDatePicker({required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate:
              formData.expiryDate ?? now.add(const Duration(days: 365)),
          firstDate: now,
          lastDate: now.add(const Duration(days: 3650)),
        );
        if (picked != null) {
          ref.read(medicationFormProvider.notifier).setExpiryDate(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: formData.expiryDate != null
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formData.expiryDate != null
                    ? _formatDate(formData.expiryDate!)
                    : l10n.tapToSetExpiryDate,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: formData.expiryDate != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontWeight:
                      formData.expiryDate != null ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (formData.expiryDate != null)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => ref
                    .read(medicationFormProvider.notifier)
                    .setExpiryDate(null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _ExpiryReminderChips extends ConsumerWidget {
  const _ExpiryReminderChips({required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [7, 14, 30, 60, 90].map((days) {
        final isSelected = formData.reminderDaysBeforeExpiry == days;
        return FilterChip(
          label: Text('$days day${days != 1 ? 's' : ''}'),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref
                  .read(medicationFormProvider.notifier)
                  .setReminderDaysBeforeExpiry(days);
            }
          },
          backgroundColor: colorScheme.surface,
          selectedColor: colorScheme.errorContainer,
          checkmarkColor: colorScheme.error,
          labelStyle: TextStyle(
            color: isSelected
                ? colorScheme.onErrorContainer
                : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        );
      }).toList(),
    );
  }
}
