class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String category;
  final String priority;
  final String? orderId;
  final String? productId;
  final bool isRead;
  final DateTime? readAt;
  final String? actionLink;
  final String? actionType;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    this.message = '',
    this.type = 'ORDER',
    this.category = 'orders',
    this.priority = 'medium',
    this.orderId,
    this.productId,
    this.isRead = false,
    this.readAt,
    this.actionLink,
    this.actionType,
    this.metadata,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      type: json['type'] ?? 'ORDER',
      category: json['category'] ?? _categoryFromType(json['type'] ?? 'ORDER'),
      priority: json['priority'] ?? 'medium',
      orderId: json['orderId'] is Map
          ? json['orderId']['_id'] ?? json['orderId']['id']
          : json['orderId'],
      productId: json['productId'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      actionLink: json['actionLink'],
      actionType: json['actionType'],
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
    );
  }

  static String _categoryFromType(String type) {
    switch (type) {
      case 'ORDER':
        return 'orders';
      case 'DELIVERY':
        return 'deliveries';
      case 'CHAT':
        return 'messages';
      case 'PROMOTION':
        return 'promotions';
      case 'SYSTEM':
        return 'system';
      case 'SECURITY':
        return 'security';
      case 'INVENTORY':
        return 'inventory';
      case 'ACCOUNT':
        return 'account';
      default:
        return 'system';
    }
  }

  String get categoryIcon {
    switch (category) {
      case 'orders':
        return '🛒';
      case 'deliveries':
        return '🚚';
      case 'messages':
        return '💬';
      case 'promotions':
        return '🎉';
      case 'system':
        return '⚙️';
      case 'security':
        return '🔒';
      case 'inventory':
        return '📦';
      case 'account':
        return '👤';
      default:
        return '🔔';
    }
  }

  bool get isHighPriority => priority == 'high' || priority == 'critical';
}
