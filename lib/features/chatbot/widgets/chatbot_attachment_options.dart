import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/ai/multi_ai_service.dart';

/// Attachment options bottom sheet for chatbot
class ChatbotAttachmentOptions extends StatelessWidget {
  const ChatbotAttachmentOptions({
    required this.aiService,
    required this.onPromptSelected,
    super.key,
  });

  final MultiAIService aiService;
  final Function(String) onPromptSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.quickTips),
            onTap: () {
              Navigator.pop(context);
              onPromptSelected(l10n.giveMeMedicationTips);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: Text(l10n.suggestQuestions),
            onTap: () {
              Navigator.pop(context);
              final prompts = aiService.getSuggestedPrompts();
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.suggestedQuestions),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: prompts.map((String prompt) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(prompt),
                        onTap: () {
                          Navigator.pop(context);
                          onPromptSelected(prompt);
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context,
    MultiAIService aiService,
    Function(String) onPromptSelected,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => ChatbotAttachmentOptions(
        aiService: aiService,
        onPromptSelected: onPromptSelected,
      ),
    );
  }
}
