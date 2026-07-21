class SecuritySettingsModel {
  final bool biometricAuth;
  final bool twoFactorAuth;
  final int sessionTimeout;
  final List<String> trustedDevices;

  SecuritySettingsModel({
    this.biometricAuth = false,
    this.twoFactorAuth = false,
    this.sessionTimeout = 30,
    this.trustedDevices = const [],
  });

  factory SecuritySettingsModel.fromJson(Map<String, dynamic> json) {
    return SecuritySettingsModel(
      biometricAuth: json['biometricAuth'] ?? false,
      twoFactorAuth: json['twoFactorAuth'] ?? false,
      sessionTimeout: json['sessionTimeout'] ?? 30,
      trustedDevices: json['trustedDevices'] != null
          ? List<String>.from(json['trustedDevices'])
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'biometricAuth': biometricAuth,
    'twoFactorAuth': twoFactorAuth,
    'sessionTimeout': sessionTimeout,
    'trustedDevices': trustedDevices,
  };

  SecuritySettingsModel copyWith({
    bool? biometricAuth,
    bool? twoFactorAuth,
    int? sessionTimeout,
    List<String>? trustedDevices,
  }) {
    return SecuritySettingsModel(
      biometricAuth: biometricAuth ?? this.biometricAuth,
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      trustedDevices: trustedDevices ?? this.trustedDevices,
    );
  }
}
