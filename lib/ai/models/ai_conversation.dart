import 'ai_chat_message.dart';

class AiConversation {
  final String id;
  final List<AiChatMessage> messages;
  final String context;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? title;

  AiConversation({
    this.id = '',
    this.messages = const [],
    this.context = 'general',
    this.metadata = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
    this.title,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory AiConversation.fromJson(Map<String, dynamic> json) => AiConversation(
    id: json['_id'] ?? json['id'] ?? '',
    messages: (json['messages'] as List?)?.map((e) => AiChatMessage.fromJson(e)).toList() ?? [],
    context: json['context'] ?? 'general',
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    title: json['title'],
  );

  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (messages.isNotEmpty) {
      final firstUser = messages.firstWhere(
        (m) => m.role == 'user',
        orElse: () => messages.first,
      );
      final text = firstUser.content;
      return text.length > 40 ? '${text.substring(0, 40)}...' : text;
    }
    return 'New conversation';
  }
}
