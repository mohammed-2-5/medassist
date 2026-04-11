import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class TimesPerDaySelector extends ConsumerWidget {
  const TimesPerDaySelector({super.key, required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.howManyTimesPerDay,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.selectTimesPerDayDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(6, (index) {
            final times = index + 1;
            final isSelected = formData.timesPerDay == times;
            return _TimesChip(
              times: times,
              isSelected: isSelected,
              onTap: () {
                ref.read(medicationFormProvider.notifier).setTimesPerDay(times);
              },
            );
          }),
        ),
      ],
    );
  }
}

class _TimesChip extends StatelessWidget {
  const _TimesChip({
    required this.times,
    required this.isSelected,
    required this.onTap,
  });

  final int times;
  final bool isSelected;
  final VoidCallback onTap;

  LinearGradient _getGradientForTimes(int times) {
    final gradients = [
      AppColors.primaryGradient,
      AppColors.purpleGradient,
      AppColors.successGradient,
      AppColors.pinkGradient,
      AppColors.warningGradient,
      const LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF66BB6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    return gradients[(times - 1) % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gradient = _getGradientForTimes(times);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : colorScheme.outlineVariant.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$times',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              times == 1
                  ? AppLocalizations.of(context)!.timeSingular
                  : AppLocalizations.of(context)!.timePlural,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              )
                  .animate()
                  .scale(duration: 300.ms, curve: Curves.elasticOut)
                  .fadeIn(),
            ],
          ],
        ),
      ),
    );
  }
}
