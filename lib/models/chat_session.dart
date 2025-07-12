// models/chat_session.dart
import 'chat_message.dart';

class ChatSession {
  final String id;
  final String sessionName;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.sessionName,
    required this.createdAt,
    required this.messages,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] ?? "",
    sessionName: json['name'] ?? "",
    createdAt: DateTime.tryParse(json['createdDate'] ?? "") ?? DateTime.now(),
    messages: (json['messages'] as List?)?.map((e) => ChatMessage.fromJson(e)).toList() ?? [],
  );
}
