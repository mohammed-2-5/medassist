import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/models/snooze_history.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Beautiful dialog for smart snooze options
class SmartSnoozeDialog extends StatelessWidget {

  const SmartSnoozeDialog({
    required this.medicationName, required this.currentSnoozeCount, required this.maxSnoozes, required this.onTakeNow, required this.onSnooze, required this.onSkip, super.key,
    this.nextDoseTime,
  });
  final String medicationName;
  final int currentSnoozeCount;
  final int maxSnoozes;
  final DateTime? nextDoseTime;
  final VoidCallback onTakeNow;
  final Function(int minutes) onSnooze;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final suggestions = SnoozeSuggestion.getSmartSuggestions(
      now: DateTime.now(),
      nextDoseTime: nextDoseTime,
      maxSnoozes: maxSnoozes,
      currentSnoozeCount: currentSnoozeCount,
    );

    final remainingSnoozes = (maxSnoozes - currentSnoozeCount).clamp(0, maxSnoozes);
    final isLimitReached = remainingSnoozes == 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLimitReached
                        ? colorScheme.errorContainer
                        : colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLimitReached ? Icons.block : Icons.snooze,
                    color: isLimitReached
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicationName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLimitReached
                            ? l10n.snoozeLimitReached
                            : l10n.snoozeRemaining(remainingSnoozes),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isLimitReached
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 24),

            // Snooze suggestions
            if (isLimitReached) ...[
              _buildLimitReachedMessage(context, l10n, colorScheme),
            ] else ...[
              _buildSuggestions(context, suggestions, theme, colorScheme, l10n),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onSkip();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.skip),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onTakeNow();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colorScheme.primary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.takeNow),
                      ],
                    ),
                  ),
                ),
              ],
            )
                .animate(delay: 300.ms)
                .fadeIn()
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitReachedMessage(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.snoozeLimitMessage,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildSuggestions(
    BuildContext context,
    List<SnoozeSuggestion> suggestions,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.snoozeOptions,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.asMap().entries.map((entry) {
          final index = entry.key;
          final suggestion = entry.value;

          return _buildSuggestionTile(
            context: context,
            suggestion: suggestion,
            index: index,
            theme: theme,
            colorScheme: colorScheme,
          ).animate(delay: (100 * index).ms).fadeIn().slideX(
                begin: -0.1,
                end: 0,
                curve: Curves.easeOutCubic,
              );
        }),
      ],
    );
  }

  Widget _buildSuggestionTile({
    required BuildContext context,
    required SnoozeSuggestion suggestion,
    required int index,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
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
                  Icons.arrow_forward_ios,
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
    );
  }
}
