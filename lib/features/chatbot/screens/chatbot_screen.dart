import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/chatbot/models/chat_message.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_app_bar.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_attachment_options.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_chat_bubble.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_input_area.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_suggested_prompts.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_typing_indicator.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/ai/medication_context_service.dart';
import 'package:med_assist/services/ai/multi_ai_service.dart';

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
          final l10n = AppLocalizations.of(context)!;
          _quickSuggestions = [
            l10n.chatSuggestion1,
            l10n.chatSuggestion2,
            l10n.chatSuggestion3,
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

      final response = await _aiService
          .sendMessage(text, medicationContext: medicationContext)
          .timeout(const Duration(seconds: 30));

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

  void _clearChat() {
    setState(_messages.clear);
    _aiService.clearHistory();
    _currentAiProvider = null;
    final l10n = AppLocalizations.of(context)!;
    _addBotMessage(l10n.chatClearedMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatbotAppBar(
        currentAiProvider: _currentAiProvider,
        onClear: _clearChat,
      ),
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
}
