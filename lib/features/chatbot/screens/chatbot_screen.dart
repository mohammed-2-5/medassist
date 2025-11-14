import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/chatbot/models/chat_message.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_attachment_options.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_chat_bubble.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_input_area.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_suggested_prompts.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_typing_indicator.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/ai/multi_ai_service.dart';
import 'package:med_assist/services/ai/medication_context_service.dart';

/// AI Chatbot Screen for medication assistance
class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final MultiAIService _aiService = MultiAIService();

  MedicationContextService? _contextService;
  List<String> _quickSuggestions = [];
  bool _isLoadingSuggestions = true;
  bool _isTyping = false;
  String? _currentAiProvider;

  @override
  void initState() {
    super.initState();
    _aiService.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final db = ref.read(appDatabaseProvider);
        _contextService = MedicationContextService(db);

        final l10n = AppLocalizations.of(context)!;
        _addBotMessage(l10n.chatbotWelcomeMessage);
        _loadQuickSuggestions();
      }
    });
  }

  Future<void> _loadQuickSuggestions() async {
    if (_contextService == null) return;

    try {
      final suggestions = await _contextService!.getQuickSuggestions();
      if (mounted) {
        setState(() {
          _quickSuggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
          _quickSuggestions = [
            'How do I add my first medication?',
            'What should I know about my medications?',
            'Help me understand adherence',
          ];
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _aiService.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    _addUserMessage(text);
    _messageController.clear();

    setState(() => _isTyping = true);

    try {
      String? medicationContext;
      if (_contextService != null) {
        try {
          medicationContext = await _contextService!.getMedicationContext();
        } catch (e) {
          medicationContext = null;
        }
      }

      final response = await _aiService.sendMessage(
        text,
        medicationContext: medicationContext,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _currentAiProvider = _aiService.lastUsedApi;
        });
        _addBotMessage(response);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        final l10n = AppLocalizations.of(context)!;
        _addBotMessage(l10n.chatbotErrorMessage);
      }
    }
  }

  void _handlePromptSelected(String prompt) {
    _messageController.text = prompt;
    _handleSendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _buildAppBar(l10n, theme, colorScheme),
      body: Column(
        children: [
          if (_messages.length == 1)
            ChatbotSuggestedPrompts(
              quickSuggestions: _quickSuggestions,
              fallbackPrompts: _aiService.getSuggestedPrompts(),
              isLoading: _isLoadingSuggestions,
              onPromptSelected: _handlePromptSelected,
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const ChatbotTypingIndicator();
                }
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          ChatbotInputArea(
            controller: _messageController,
            onSend: _handleSendMessage,
            onShowOptions: () => ChatbotAttachmentOptions.show(
              context,
              _aiService,
              _handlePromptSelected,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
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
                  if (_currentAiProvider != null) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getProviderColor(_currentAiProvider!),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentAiProvider!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getProviderColor(_currentAiProvider!),
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
          onSelected: (value) {
            if (value == 'clear') {
              _clearChat();
            }
          },
          itemBuilder: (context) => [
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

  void _clearChat() {
    setState(_messages.clear);
    _aiService.clearHistory();
    _currentAiProvider = null;
    final l10n = AppLocalizations.of(context)!;
    _addBotMessage(l10n.chatClearedMessage);
  }

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
}
