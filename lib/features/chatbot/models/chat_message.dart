class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.aiProvider,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['message'] as String,
      isUser: (map['is_user'] as int) == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      aiProvider: map['ai_provider'] as String?,
    );
  }

  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? aiProvider;
}
