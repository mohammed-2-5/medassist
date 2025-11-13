import 'package:flutter/material.dart';
import 'package:med_assist/core/models/meal_timing.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Widget for selecting meal timing for a medication reminder
class MealTimingSelector extends StatelessWidget {

  const MealTimingSelector({
    required this.selectedTiming, required this.onChanged, super.key,
  });
  final MealTiming selectedTiming;
  final ValueChanged<MealTiming> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mealTiming,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MealTiming.values.map((timing) {
            final isSelected = timing == selectedTiming;
            return ChoiceChip(
              label: Text(_getLocalizedLabel(timing, l10n)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onChanged(timing);
                }
              },
              selectedColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              avatar: isSelected
                  ? Icon(
                      _getIcon(timing),
                      size: 18,
                      color: colorScheme.onPrimaryContainer,
                    )
                  : null,
            );
          }).toList(),
        ),
        if (selectedTiming != MealTiming.anytime) ...[
          const SizedBox(height: 8),
          Text(
            _getDescription(selectedTiming, l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  String _getLocalizedLabel(MealTiming timing, AppLocalizations l10n) {
    switch (timing) {
      case MealTiming.anytime:
        return l10n.anytime;
      case MealTiming.beforeMeal:
        return l10n.beforeMeal;
      case MealTiming.withMeal:
        return l10n.withMeal;
      case MealTiming.afterMeal:
        return l10n.afterMeal;
    }
  }

  IconData _getIcon(MealTiming timing) {
    switch (timing) {
      case MealTiming.anytime:
        return Icons.schedule;
      case MealTiming.beforeMeal:
        return Icons.schedule_outlined;
      case MealTiming.withMeal:
        return Icons.restaurant;
      case MealTiming.afterMeal:
        return Icons.schedule;
    }
  }

  String _getDescription(MealTiming timing, AppLocalizations l10n) {
    switch (timing) {
      case MealTiming.anytime:
        return '';
      case MealTiming.beforeMeal:
        return l10n.beforeMealDescription;
      case MealTiming.withMeal:
        return l10n.withMealDescription;
      case MealTiming.afterMeal:
        return l10n.afterMealDescription;
    }
  }
}
