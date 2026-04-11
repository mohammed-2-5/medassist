import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/models/snooze_history.dart';
import 'package:med_assist/features/home/widgets/snooze_suggestion_tile.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Beautiful dialog for smart snooze options
class SmartSnoozeDialog extends StatelessWidget {
  const SmartSnoozeDialog({
    required this.medicationName,
    required this.currentSnoozeCount,
    required this.maxSnoozes,
    required this.onTakeNow,
    required this.onSnooze,
    required this.onSkip,
    super.key,
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

            if (isLimitReached)
              _buildLimitReachedMessage(context, l10n, colorScheme)
            else
              _buildSuggestions(context, suggestions, l10n),

            const SizedBox(height: 24),

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
          Icon(Icons.info_outline, color: colorScheme.error, size: 24),
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
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        ...suggestions.asMap().entries.map(
          (entry) => SnoozeSuggestionTile(
            suggestion: entry.value,
            index: entry.key,
            onSnooze: onSnooze,
          ),
        ),
      ],
    );
  }
}
