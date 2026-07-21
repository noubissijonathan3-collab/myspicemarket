class PrivacySettingsModel {
  final bool dataSharing;
  final bool analytics;
  final bool cookieConsent;

  PrivacySettingsModel({
    this.dataSharing = false,
    this.analytics = true,
    this.cookieConsent = false,
  });

  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) {
    return PrivacySettingsModel(
      dataSharing: json['dataSharing'] ?? false,
      analytics: json['analytics'] ?? true,
      cookieConsent: json['cookieConsent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'dataSharing': dataSharing,
    'analytics': analytics,
    'cookieConsent': cookieConsent,
  };

  PrivacySettingsModel copyWith({
    bool? dataSharing,
    bool? analytics,
    bool? cookieConsent,
  }) {
    return PrivacySettingsModel(
      dataSharing: dataSharing ?? this.dataSharing,
      analytics: analytics ?? this.analytics,
      cookieConsent: cookieConsent ?? this.cookieConsent,
    );
  }
}
