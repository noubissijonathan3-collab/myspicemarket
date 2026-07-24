class AiChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final List<String> suggestedActions;
  final String? productId;
  final String? productName;
  final double? productPrice;
  final String? productImage;

  AiChatMessage({
    this.id = '',
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.suggestedActions = const [],
    this.productId,
    this.productName,
    this.productPrice,
    this.productImage,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AiChatMessage.fromJson(Map<String, dynamic> json) => AiChatMessage(
    id: json['_id'] ?? json['id'] ?? '',
    role: json['role'] ?? 'user',
    content: json['content'] ?? '',
    timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    suggestedActions: List<String>.from(json['suggestedActions'] ?? []),
    productId: json['productId'],
    productName: json['productName'],
    productPrice: (json['productPrice'] as num?)?.toDouble(),
    productImage: json['productImage'],
  );

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    if (suggestedActions.isNotEmpty) 'suggestedActions': suggestedActions,
    if (productId != null) 'productId': productId,
    if (productName != null) 'productName': productName,
    if (productPrice != null) 'productPrice': productPrice,
    if (productImage != null) 'productImage': productImage,
  };

  AiChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    List<String>? suggestedActions,
    String? productId,
    String? productName,
    double? productPrice,
    String? productImage,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImage: productImage ?? this.productImage,
    );
  }
}
