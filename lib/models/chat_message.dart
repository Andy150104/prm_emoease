// models/chat_message.dart
class ChatMessage {
  final String id;
  final String content;
  final String sender; // 'user' | 'ai'
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] ?? "",
    content: json['content'] ?? "",
    sender: (json['senderIsEmo'] ?? false) ? 'ai' : 'user',
    timestamp: DateTime.tryParse(json['createdDate'] ?? json['timestamp'] ?? "") ?? DateTime.now(),
  );
}
