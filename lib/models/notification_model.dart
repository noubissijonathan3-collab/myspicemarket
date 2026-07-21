class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String? image;
  final String? link;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    this.body = '',
    this.type = 'info',
    this.isRead = false,
    this.image,
    this.link,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      type: json['type'] ?? 'info',
      isRead: json['isRead'] ?? false,
      image: json['image'],
      link: json['link'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'type': type,
    'isRead': isRead,
    'image': image,
    'link': link,
  };
}
