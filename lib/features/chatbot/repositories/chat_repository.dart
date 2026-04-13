import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/chatbot/models/chat_message.dart';
import 'package:med_assist/features/chatbot/models/chat_session.dart';

/// Repository that maps raw chat persistence rows into feature models.
class ChatRepository {
  ChatRepository(this._database);

  final AppDatabase _database;

  Future<String> createSession({String title = ''}) {
    return _database.createChatSession(title: title);
  }

  Future<List<ChatSession>> getAllSessions() async {
    final rows = await _database.getAllChatSessions();
    return rows.map(_mapSession).toList();
  }

  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final rows = await _database.getChatMessages(sessionId);
    return rows.map(_mapMessage).toList();
  }

  Future<void> updateSessionTitle(String sessionId, String title) {
    return _database.updateChatSessionTitle(sessionId, title);
  }

  Future<void> addMessage({
    required String sessionId,
    required String message,
    required bool isUser,
    String? aiProvider,
  }) {
    return _database.insertChatMessage(
      sessionId: sessionId,
      message: message,
      isUser: isUser,
      aiProvider: aiProvider,
    );
  }

  Future<void> deleteSession(String sessionId) {
    return _database.deleteChatSession(sessionId);
  }

  Future<void> deleteAllSessions() {
    return _database.deleteAllChatSessions();
  }

  ChatSession _mapSession(Map<String, dynamic> row) {
    return ChatSession(
      id: row['id'].toString(),
      title: (row['title'] as String?) ?? '',
      createdAt: _msToDateTime(row['created_at']),
      updatedAt: _msToDateTime(row['updated_at']),
      messageCount: _toInt(row['message_count']),
    );
  }

  ChatMessage _mapMessage(Map<String, dynamic> row) {
    return ChatMessage(
      text: (row['message'] as String?) ?? '',
      isUser: (row['is_user'] as int?) == 1,
      timestamp: _msToDateTime(row['created_at']),
      aiProvider: row['ai_provider'] as String?,
    );
  }

  DateTime _msToDateTime(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed);
      }
    }
    return DateTime.now();
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
