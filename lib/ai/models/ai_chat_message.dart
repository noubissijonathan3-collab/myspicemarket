class AiChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;

  AiChatMessage({
    this.id = '',
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AiChatMessage.fromJson(Map<String, dynamic> json) => AiChatMessage(
    id: json['_id'] ?? json['id'] ?? '',
    role: json['role'] ?? 'user',
    content: json['content'] ?? '',
    timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };
}
