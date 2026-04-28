import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Loading state shown while AI drug info is being fetched.
class DrugInfoLoadingCard extends StatelessWidget {
  const DrugInfoLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.drugInfoFetching,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Error state shown when AI drug info fetch fails. Tapping retries.
class DrugInfoErrorCard extends StatelessWidget {
  const DrugInfoErrorCard({
    required this.onRetry,
    this.suggestions = const [],
    this.onSuggestionTap,
    super.key,
  });

  final VoidCallback onRetry;
  final List<String> suggestions;
  final void Function(String name)? onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final hasSuggestions = suggestions.isNotEmpty && onSuggestionTap != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, color: colorScheme.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasSuggestions
                          ? l10n.drugInfoDidYouMean
                          : l10n.drugInfoFetchError,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasSuggestions) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in suggestions)
                  ActionChip(
                    label: Text(name),
                    onPressed: () => onSuggestionTap!(name),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
