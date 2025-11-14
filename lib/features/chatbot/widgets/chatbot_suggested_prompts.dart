import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Suggested prompts widget for chatbot
class ChatbotSuggestedPrompts extends StatelessWidget {
  const ChatbotSuggestedPrompts({
    required this.quickSuggestions,
    required this.fallbackPrompts,
    required this.isLoading,
    required this.onPromptSelected,
    super.key,
  });

  final List<String> quickSuggestions;
  final List<String> fallbackPrompts;
  final bool isLoading;
  final Function(String) onPromptSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final prompts = quickSuggestions.isNotEmpty
        ? quickSuggestions
        : fallbackPrompts.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                quickSuggestions.isNotEmpty
                    ? 'Quick Actions'
                    : l10n.suggestedQuestions,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prompts.map((String prompt) {
                return ActionChip(
                  avatar: Icon(
                    quickSuggestions.isNotEmpty
                        ? Icons.medication
                        : Icons.lightbulb_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    prompt,
                    style: const TextStyle(fontSize: 13),
                  ),
                  onPressed: () => onPromptSelected(prompt),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  side: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                );
              }).toList(),
            ),
          const Divider(height: 32),
        ],
      ),
    );
  }
}
