import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
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

    // Initialize Multi-AI service with intelligent fallback
    _aiService.initialize();

    // Add welcome message after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Initialize context service
        final db = ref.read(appDatabaseProvider);
        _contextService = MedicationContextService(db);

        final l10n = AppLocalizations.of(context)!;
        _addBotMessage(l10n.chatbotWelcomeMessage);

        // Load medication-aware suggestions
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
          // Fallback to generic suggestions
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

    // Show typing indicator
    setState(() => _isTyping = true);

    try {
      // Get medication context for more relevant responses
      String? medicationContext;
      if (_contextService != null) {
        try {
          medicationContext = await _contextService!.getMedicationContext();
        } catch (e) {
          // Context is optional, continue without it
          medicationContext = null;
        }
      }

      // Get AI response with intelligent fallback (Groq → Gemini → HuggingFace)
      final response = await _aiService.sendMessage(
        text,
        medicationContext: medicationContext,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          // Track which AI provider was used
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Column(
        children: [
          // Suggested prompts (show when empty)
          if (_messages.length == 1) _buildSuggestedPrompts(colorScheme),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // Show typing indicator at the end
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),

          // Input area
          _buildInputArea(colorScheme),
        ],
      ),
    );
  }

  void _clearChat() {
    setState(_messages.clear);
    _aiService.clearHistory();
    _currentAiProvider = null; // Reset provider indicator
    final l10n = AppLocalizations.of(context)!;
    _addBotMessage(l10n.chatClearedMessage);
  }

  /// Get color for AI provider indicator
  Color _getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'groq':
        return const Color(0xFF8B5CF6); // Purple for Groq
      case 'gemini':
        return const Color(0xFF4285F4); // Blue for Gemini
      case 'huggingface':
        return const Color(0xFFFFD21E); // Yellow for HuggingFace
      case 'offline':
        return Colors.grey; // Grey for offline
      default:
        return Colors.teal; // Teal for unknown
    }
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.aiIsThinking,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPrompts(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;

    // Use medication-aware suggestions if available, otherwise use generic ones
    final prompts = _quickSuggestions.isNotEmpty
        ? _quickSuggestions
        : _geminiService.getSuggestedPrompts().take(4).toList();

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
                _quickSuggestions.isNotEmpty
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
          if (_isLoadingSuggestions)
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
              children: prompts.map((prompt) {
                return ActionChip(
                  avatar: Icon(
                    _quickSuggestions.isNotEmpty
                        ? Icons.medication
                        : Icons.lightbulb_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    prompt,
                    style: const TextStyle(fontSize: 13),
                  ),
                  onPressed: () {
                    _messageController.text = prompt;
                    _handleSendMessage();
                  },
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

  void _showAttachmentOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(l10n.quickTips),
              onTap: () {
                Navigator.pop(context);
                _messageController.text = l10n.giveMeMedicationTips;
                _handleSendMessage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(l10n.suggestQuestions),
              onTap: () {
                Navigator.pop(context);
                final prompts = _geminiService.getSuggestedPrompts();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.suggestedQuestions),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: prompts.map((prompt) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(prompt),
                          onTap: () {
                            Navigator.pop(context);
                            _messageController.text = prompt;
                            _handleSendMessage();
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
      ),
    );
  }

  Widget _buildInputArea(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button (for future features)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _showAttachmentOptions,
              tooltip: l10n.moreOptions,
            ),

            // Text input
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: l10n.askAboutMedications,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            IconButton(
              icon: Icon(
                Icons.send,
                color: colorScheme.primary,
              ),
              onPressed: _handleSendMessage,
              tooltip: l10n.send,
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat message widget
class _ChatBubble extends StatelessWidget {

  const _ChatBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: message.isUser ? const Radius.circular(4) : null,
                  bottomLeft: !message.isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: message.isUser
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month} ${time.hour}:${time.minute}';
  }
}

/// Chat message model
class ChatMessage {

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
  final String text;
  final bool isUser;
  final DateTime timestamp;
}
