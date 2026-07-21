class NotificationSettingsModel {
  final bool orderUpdates;
  final bool promotions;
  final bool discounts;
  final bool newProducts;
  final bool deliveryUpdates;
  final bool aiRecommendations;
  final bool chatMessages;
  final bool supportMessages;
  final bool securityAlerts;
  final bool accountActivity;
  final String sound;
  final bool vibration;
  final bool previews;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;

  NotificationSettingsModel({
    this.orderUpdates = true,
    this.promotions = true,
    this.discounts = true,
    this.newProducts = false,
    this.deliveryUpdates = true,
    this.aiRecommendations = true,
    this.chatMessages = true,
    this.supportMessages = true,
    this.securityAlerts = true,
    this.accountActivity = true,
    this.sound = 'default',
    this.vibration = true,
    this.previews = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      orderUpdates: json['orderUpdates'] ?? true,
      promotions: json['promotions'] ?? true,
      discounts: json['discounts'] ?? true,
      newProducts: json['newProducts'] ?? false,
      deliveryUpdates: json['deliveryUpdates'] ?? true,
      aiRecommendations: json['aiRecommendations'] ?? true,
      chatMessages: json['chatMessages'] ?? true,
      supportMessages: json['supportMessages'] ?? true,
      securityAlerts: json['securityAlerts'] ?? true,
      accountActivity: json['accountActivity'] ?? true,
      sound: json['sound'] ?? 'default',
      vibration: json['vibration'] ?? true,
      previews: json['previews'] ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] ?? false,
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '07:00',
    );
  }

  Map<String, dynamic> toJson() => {
    'orderUpdates': orderUpdates,
    'promotions': promotions,
    'discounts': discounts,
    'newProducts': newProducts,
    'deliveryUpdates': deliveryUpdates,
    'aiRecommendations': aiRecommendations,
    'chatMessages': chatMessages,
    'supportMessages': supportMessages,
    'securityAlerts': securityAlerts,
    'accountActivity': accountActivity,
    'sound': sound,
    'vibration': vibration,
    'previews': previews,
    'quietHoursEnabled': quietHoursEnabled,
    'quietHoursStart': quietHoursStart,
    'quietHoursEnd': quietHoursEnd,
  };

  NotificationSettingsModel copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? discounts,
    bool? newProducts,
    bool? deliveryUpdates,
    bool? aiRecommendations,
    bool? chatMessages,
    bool? supportMessages,
    bool? securityAlerts,
    bool? accountActivity,
    String? sound,
    bool? vibration,
    bool? previews,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationSettingsModel(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      discounts: discounts ?? this.discounts,
      newProducts: newProducts ?? this.newProducts,
      deliveryUpdates: deliveryUpdates ?? this.deliveryUpdates,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
      chatMessages: chatMessages ?? this.chatMessages,
      supportMessages: supportMessages ?? this.supportMessages,
      securityAlerts: securityAlerts ?? this.securityAlerts,
      accountActivity: accountActivity ?? this.accountActivity,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      previews: previews ?? this.previews,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
