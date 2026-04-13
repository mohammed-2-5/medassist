import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// App bar for the AI chatbot screen, showing current AI provider status.
class ChatbotAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatbotAppBar({
    required this.currentAiProvider,
    required this.onClear,
    required this.onShowHistory,
    required this.onNewChat,
    super.key,
  });

  final String? currentAiProvider;
  final VoidCallback onClear;
  final VoidCallback onShowHistory;
  final VoidCallback onNewChat;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Color _getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'groq':
        return const Color(0xFF8B5CF6);
      case 'gemini':
        return const Color(0xFF4285F4);
      case 'huggingface':
        return const Color(0xFFFFD21E);
      case 'offline':
        return Colors.grey;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aiAssistant,
                style: theme.textTheme.titleMedium,
              ),
              Row(
                children: [
                  if (currentAiProvider != null) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getProviderColor(currentAiProvider!),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currentAiProvider!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getProviderColor(currentAiProvider!),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    l10n.alwaysHereToHelp,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'history') onShowHistory();
            if (value == 'new') onNewChat();
            if (value == 'clear') onClear();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  const Icon(Icons.history),
                  const SizedBox(width: 12),
                  Text(l10n.chatHistory),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'new',
              child: Row(
                children: [
                  const Icon(Icons.add_comment_outlined),
                  const SizedBox(width: 12),
                  Text(l10n.newChat),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline),
                  const SizedBox(width: 12),
                  Text(l10n.clearChat),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
