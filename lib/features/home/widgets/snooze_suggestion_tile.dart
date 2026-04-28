import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/models/snooze_history.dart';

/// A single tappable snooze option tile in the smart snooze dialog.
class SnoozeSuggestionTile extends StatelessWidget {
  const SnoozeSuggestionTile({
    required this.suggestion,
    required this.index,
    required this.onSnooze,
    super.key,
  });

  final SnoozeSuggestion suggestion;
  final int index;
  final ValueChanged<int> onSnooze;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRecommended = suggestion.isRecommended;

    return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isRecommended
                ? colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                onSnooze(suggestion.minutes);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isRecommended
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: isRecommended ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isRecommended
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.schedule,
                        size: 20,
                        color: isRecommended
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                suggestion.label,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: isRecommended
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isRecommended
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              if (isRecommended) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Recommended',
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            suggestion.reason,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_back_ios
                          : Icons.arrow_forward_ios,
                      size: 16,
                      color: isRecommended
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (100 * index).ms)
        .fadeIn()
        .slideX(begin: -0.1, end: 0, curve: Curves.easeOutCubic);
  }
}
