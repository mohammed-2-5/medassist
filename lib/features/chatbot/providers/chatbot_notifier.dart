import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/chatbot/models/chat_message.dart';
import 'package:med_assist/features/chatbot/providers/chat_providers.dart';
import 'package:med_assist/features/chatbot/utils/chatbot_ai_helper.dart';
import 'package:med_assist/services/ai/multi_ai_service.dart';

class ChatbotState {
  const ChatbotState({
    this.messages = const [],
    this.currentSessionId,
    this.currentAiProvider,
    this.isTyping = false,
    this.isInitializing = true,
  });

  final List<ChatMessage> messages;
  final String? currentSessionId;
  final String? currentAiProvider;
  final bool isTyping;
  final bool isInitializing;

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    String? Function()? currentSessionId,
    String? Function()? currentAiProvider,
    bool? isTyping,
    bool? isInitializing,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      currentSessionId: currentSessionId != null
          ? currentSessionId()
          : this.currentSessionId,
      currentAiProvider: currentAiProvider != null
          ? currentAiProvider()
          : this.currentAiProvider,
      isTyping: isTyping ?? this.isTyping,
      isInitializing: isInitializing ?? this.isInitializing,
    );
  }
}

class ChatbotNotifier extends Notifier<ChatbotState> {
  late final MultiAIService _aiService;

  @override
  ChatbotState build() {
    _aiService = MultiAIService()..initialize();
    ref.onDispose(_aiService.dispose);
    unawaited(Future.microtask(() => loadOrCreateSession(setReady: true)));
    return const ChatbotState();
  }

  MultiAIService get aiService => _aiService;

  Future<void> loadOrCreateSession({
    bool setReady = false,
    String? welcomeMessage,
  }) async {
    final repo = ref.read(chatRepositoryProvider);
    final sessions = await repo.getAllSessions();
    final id = sessions.isNotEmpty
        ? sessions.first.id
        : await repo.createSession();
    await loadSession(id, welcomeMessage: welcomeMessage);
    if (setReady) state = state.copyWith(isInitializing: false);
  }

  Future<void> loadSession(
    String sessionId, {
    String? welcomeMessage,
  }) async {
    _aiService.clearHistory();
    final messages = await ref
        .read(chatRepositoryProvider)
        .getMessages(sessionId);
    state = state.copyWith(
      messages: List.of(messages),
      currentSessionId: () => sessionId,
      currentAiProvider: () => null,
    );
    if (messages.isEmpty && welcomeMessage != null) {
      await addMessage(
        welcomeMessage,
        isUser: false,
        persist: true,
        aiProvider: 'system',
      );
    }
  }

  Future<void> addMessage(
    String text, {
    required bool isUser,
    bool persist = false,
    String? aiProvider,
  }) async {
    final msg = ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
      aiProvider: aiProvider,
    );
    state = state.copyWith(messages: [...state.messages, msg]);
    if (persist && state.currentSessionId != null) {
      await ref
          .read(chatRepositoryProvider)
          .addMessage(
            sessionId: state.currentSessionId!,
            message: text,
            isUser: isUser,
            aiProvider: aiProvider,
          );
      ref.invalidate(chatSessionsProvider);
    }
  }

  Future<void> sendMessage(String text, {String? errorMessage}) async {
    if (text.trim().isEmpty || state.isTyping) return;
    final trimmed = text.trim();

    if (state.currentSessionId == null) await loadOrCreateSession();
    if (state.currentSessionId == null) return;

    final isFirst = state.messages.where((m) => m.isUser).isEmpty;
    await addMessage(trimmed, isUser: true, persist: true);

    if (isFirst) {
      await ref
          .read(chatRepositoryProvider)
          .updateSessionTitle(
            state.currentSessionId!,
            generateSessionTitle(trimmed),
          );
      ref.invalidate(chatSessionsProvider);
    }

    state = state.copyWith(isTyping: true);
    try {
      final db = ref.read(appDatabaseProvider);
      final response = await sendAiMessage(
        trimmed,
        aiService: _aiService,
        db: db,
      );
      state = state.copyWith(
        isTyping: false,
        currentAiProvider: () => _aiService.lastUsedApi,
      );
      await addMessage(
        response,
        isUser: false,
        persist: true,
        aiProvider: state.currentAiProvider,
      );
    } on Exception {
      state = state.copyWith(isTyping: false);
      if (errorMessage != null) {
        await addMessage(errorMessage, isUser: false);
      }
    }
  }

  Future<void> createNewSession({String? welcomeMessage}) async {
    final id = await ref.read(chatRepositoryProvider).createSession();
    _aiService.clearHistory();
    state = state.copyWith(
      messages: [],
      currentSessionId: () => id,
      currentAiProvider: () => null,
    );
    if (welcomeMessage != null) {
      await addMessage(
        welcomeMessage,
        isUser: false,
        persist: true,
        aiProvider: 'system',
      );
    }
    ref.invalidate(chatSessionsProvider);
  }

  Future<void> deleteSession(String sessionId) async {
    await ref.read(chatRepositoryProvider).deleteSession(sessionId);
    ref.invalidate(chatSessionsProvider);
    if (state.currentSessionId == sessionId) {
      await loadOrCreateSession();
    }
  }

  Future<void> deleteAllSessions() async {
    await ref.read(chatRepositoryProvider).deleteAllSessions();
    ref.invalidate(chatSessionsProvider);
    _clearState();
    await loadOrCreateSession();
  }

  Future<void> clearChat() async {
    if (state.currentSessionId != null) {
      await ref
          .read(chatRepositoryProvider)
          .deleteSession(state.currentSessionId!);
    }
    ref.invalidate(chatSessionsProvider);
    _clearState();
    await loadOrCreateSession();
  }

  void _clearState() {
    _aiService.clearHistory();
    state = state.copyWith(
      messages: [],
      currentSessionId: () => null,
      currentAiProvider: () => null,
    );
  }
}

final chatbotProvider = NotifierProvider<ChatbotNotifier, ChatbotState>(
  ChatbotNotifier.new,
);
