import 'package:flutter/material.dart';
import 'package:med_assist/features/chatbot/models/chat_session.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class ChatHistorySheet extends StatelessWidget {
  const ChatHistorySheet({
    required this.sessions,
    required this.currentSessionId,
    required this.onNewChat,
    required this.onLoadSession,
    required this.onDeleteSession,
    required this.onDeleteAllSessions,
    super.key,
  });

  final List<ChatSession> sessions;
  final String? currentSessionId;
  final VoidCallback onNewChat;
  final ValueChanged<String> onLoadSession;
  final ValueChanged<String> onDeleteSession;
  final VoidCallback onDeleteAllSessions;

  static Future<void> show(
    BuildContext context, {
    required List<ChatSession> sessions,
    required String? currentSessionId,
    required VoidCallback onNewChat,
    required ValueChanged<String> onLoadSession,
    required ValueChanged<String> onDeleteSession,
    required VoidCallback onDeleteAllSessions,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChatHistorySheet(
        sessions: sessions,
        currentSessionId: currentSessionId,
        onNewChat: onNewChat,
        onLoadSession: onLoadSession,
        onDeleteSession: onDeleteSession,
        onDeleteAllSessions: onDeleteAllSessions,
      ),
    );
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            _buildHeader(context, l10n, theme),
            ListTile(
              leading: const Icon(Icons.add_comment_outlined),
              title: Text(l10n.newChat),
              onTap: () {
                Navigator.pop(context);
                onNewChat();
              },
            ),
            const Divider(height: 1),
            if (sessions.isEmpty)
              _buildEmptyState(l10n, theme, colorScheme)
            else
              _buildSessionList(context, l10n, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return ListTile(
      title: Text(
        l10n.chatHistory,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: sessions.isEmpty
          ? null
          : TextButton(
              onPressed: () async {
                final confirmed = await _confirm(
                  context,
                  title: l10n.deleteAllChats,
                  content: l10n.deleteAllChatsConfirm,
                );
                if (confirmed && context.mounted) {
                  Navigator.pop(context);
                  onDeleteAllSessions();
                }
              },
              child: Text(l10n.deleteAllChats),
            ),
    );
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 44,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(l10n.noChatHistory, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                l10n.noChatHistorySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionList(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Expanded(
      child: ListView.separated(
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final session = sessions[index];
          final isCurrent = session.id == currentSessionId;
          return ListTile(
            selected: isCurrent,
            leading: Icon(
              isCurrent ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline,
            ),
            title: Text(
              _sessionTitle(session, l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _sessionSubtitle(session, l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.pop(context);
              onLoadSession(session.id);
            },
            trailing: IconButton(
              tooltip: l10n.deleteChat,
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () async {
                final confirmed = await _confirm(
                  context,
                  title: l10n.deleteChat,
                  content: l10n.deleteChatConfirm,
                );
                if (confirmed && context.mounted) {
                  Navigator.pop(context);
                  onDeleteSession(session.id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  String _sessionTitle(ChatSession session, AppLocalizations l10n) {
    final title = session.title.trim();
    return title.isEmpty ? l10n.newChat : title;
  }

  String _sessionSubtitle(ChatSession session, AppLocalizations l10n) {
    final dateLabel = _sessionDateLabel(session.updatedAt, l10n);
    return '${l10n.messagesCount(session.messageCount)} · $dateLabel';
  }

  String _sessionDateLabel(DateTime updatedAt, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(updatedAt.year, updatedAt.month, updatedAt.day);
    final difference = today.difference(date).inDays;
    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.yesterday;
    if (difference < 7) return l10n.thisWeek;
    return l10n.older;
  }
}
