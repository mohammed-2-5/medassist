import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/chatbot/providers/chat_providers.dart';
import 'package:med_assist/features/chatbot/providers/chatbot_notifier.dart';
import 'package:med_assist/features/chatbot/widgets/chat_history_sheet.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_app_bar.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_attachment_options.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_chat_bubble.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_input_area.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_suggested_prompts.dart';
import 'package:med_assist/features/chatbot/widgets/chatbot_typing_indicator.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ChatbotNotifier get _notifier => ref.read(chatbotProvider.notifier);
  String get _welcome => AppLocalizations.of(context)!.chatbotWelcomeMessage;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        unawaited(
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    final l10n = AppLocalizations.of(context)!;
    await _notifier.sendMessage(text, errorMessage: l10n.chatbotErrorMessage);
    _scrollToBottom();
  }

  void _onPromptSelected(String prompt) {
    _messageController.text = prompt;
    unawaited(_handleSend());
  }

  Future<void> _openHistory() async {
    final sessions = await ref.read(chatRepositoryProvider).getAllSessions();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await ChatHistorySheet.show(
      context,
      sessions: sessions,
      currentSessionId: ref.read(chatbotProvider).currentSessionId,
      onNewChat: () => unawaited(
        _notifier.createNewSession(welcomeMessage: _welcome),
      ),
      onLoadSession: (id) => unawaited(
        _notifier.loadSession(id, welcomeMessage: _welcome),
      ),
      onDeleteSession: (id) => unawaited(() async {
        await _notifier.deleteSession(id);
        if (mounted) _showSnackBar(l10n.chatSessionDeleted);
      }()),
      onDeleteAllSessions: () => unawaited(() async {
        await _notifier.deleteAllSessions();
        if (mounted) _showSnackBar(l10n.allChatsDeleted);
      }()),
    );
  }

  Future<void> _clearChat() async {
    await _notifier.clearChat();
    if (mounted) {
      _showSnackBar(AppLocalizations.of(context)!.chatClearedMessage);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatbotProvider);
    final suggestionsAsync = ref.watch(quickSuggestionsProvider);

    ref.listen(chatbotProvider, (prev, next) {
      if (prev != null && next.messages.length > prev.messages.length) {
        _scrollToBottom();
      }
    });

    if (chatState.isInitializing) {
      return Scaffold(
        appBar: ChatbotAppBar(
          currentAiProvider: null,
          onClear: () {},
          onNewChat: () {},
          onShowHistory: () {},
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: ChatbotAppBar(
        currentAiProvider: chatState.currentAiProvider,
        onClear: () => unawaited(_clearChat()),
        onNewChat: () =>
            unawaited(_notifier.createNewSession(welcomeMessage: _welcome)),
        onShowHistory: () => unawaited(_openHistory()),
      ),
      body: Column(
        children: [
          if (chatState.messages.length <= 1)
            ChatbotSuggestedPrompts(
              quickSuggestions: suggestionsAsync.asData?.value ?? [],
              fallbackPrompts: _notifier.aiService.getSuggestedPrompts(),
              isLoading: suggestionsAsync.isLoading,
              onPromptSelected: _onPromptSelected,
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  chatState.messages.length + (chatState.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (chatState.isTyping && index == chatState.messages.length) {
                  return const ChatbotTypingIndicator();
                }
                return ChatBubble(message: chatState.messages[index]);
              },
            ),
          ),
          ChatbotInputArea(
            controller: _messageController,
            onSend: _handleSend,
            onShowOptions: () => ChatbotAttachmentOptions.show(
              context,
              _notifier.aiService,
              _onPromptSelected,
            ),
          ),
        ],
      ),
    );
  }
}
