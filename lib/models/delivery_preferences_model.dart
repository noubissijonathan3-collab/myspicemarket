class DeliveryPreferencesModel {
  final String defaultAddress;
  final String preferredTimeWindow;
  final String defaultPaymentMethod;
  final String deliveryInstructions;
  final String receiptPreference;
  final int orderHistoryRetention;
  final bool autoReorder;
  final bool liveTracking;
  final bool autoOpenTracking;

  DeliveryPreferencesModel({
    this.defaultAddress = '',
    this.preferredTimeWindow = '',
    this.defaultPaymentMethod = '',
    this.deliveryInstructions = '',
    this.receiptPreference = 'email',
    this.orderHistoryRetention = 365,
    this.autoReorder = false,
    this.liveTracking = true,
    this.autoOpenTracking = false,
  });

  factory DeliveryPreferencesModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPreferencesModel(
      defaultAddress: json['defaultAddress'] ?? '',
      preferredTimeWindow: json['preferredTimeWindow'] ?? '',
      defaultPaymentMethod: json['defaultPaymentMethod'] ?? '',
      deliveryInstructions: json['deliveryInstructions'] ?? '',
      receiptPreference: json['receiptPreference'] ?? 'email',
      orderHistoryRetention: json['orderHistoryRetention'] ?? 365,
      autoReorder: json['autoReorder'] ?? false,
      liveTracking: json['liveTracking'] ?? true,
      autoOpenTracking: json['autoOpenTracking'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'defaultAddress': defaultAddress,
    'preferredTimeWindow': preferredTimeWindow,
    'defaultPaymentMethod': defaultPaymentMethod,
    'deliveryInstructions': deliveryInstructions,
    'receiptPreference': receiptPreference,
    'orderHistoryRetention': orderHistoryRetention,
    'autoReorder': autoReorder,
    'liveTracking': liveTracking,
    'autoOpenTracking': autoOpenTracking,
  };

  DeliveryPreferencesModel copyWith({
    String? defaultAddress,
    String? preferredTimeWindow,
    String? defaultPaymentMethod,
    String? deliveryInstructions,
    String? receiptPreference,
    int? orderHistoryRetention,
    bool? autoReorder,
    bool? liveTracking,
    bool? autoOpenTracking,
  }) {
    return DeliveryPreferencesModel(
      defaultAddress: defaultAddress ?? this.defaultAddress,
      preferredTimeWindow: preferredTimeWindow ?? this.preferredTimeWindow,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      receiptPreference: receiptPreference ?? this.receiptPreference,
      orderHistoryRetention: orderHistoryRetention ?? this.orderHistoryRetention,
      autoReorder: autoReorder ?? this.autoReorder,
      liveTracking: liveTracking ?? this.liveTracking,
      autoOpenTracking: autoOpenTracking ?? this.autoOpenTracking,
    );
  }
}
