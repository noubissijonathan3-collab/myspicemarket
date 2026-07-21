import 'language_model.dart';
import 'theme_model.dart';
import 'notification_settings_model.dart';
import 'ai_settings_model.dart';
import 'privacy_settings_model.dart';
import 'security_settings_model.dart';
import 'delivery_preferences_model.dart';
import 'accessibility_settings_model.dart';
import 'storage_settings_model.dart';

class UserSettingsModel {
  final LanguageModel language;
  final ThemeModel theme;
  final NotificationSettingsModel notifications;
  final AiSettingsModel ai;
  final PrivacySettingsModel privacy;
  final SecuritySettingsModel security;
  final DeliveryPreferencesModel delivery;
  final AccessibilitySettingsModel accessibility;
  final StorageSettingsModel storage;

  UserSettingsModel({
    required this.language,
    required this.theme,
    required this.notifications,
    required this.ai,
    required this.privacy,
    required this.security,
    required this.delivery,
    required this.accessibility,
    required this.storage,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      language: json['language'] != null
          ? LanguageModel.fromJson(json['language'])
          : LanguageModel(code: '', name: '', nativeName: ''),
      theme: json['theme'] != null
          ? ThemeModel.fromJson(json['theme'])
          : ThemeModel(),
      notifications: json['notifications'] != null
          ? NotificationSettingsModel.fromJson(json['notifications'])
          : NotificationSettingsModel(),
      ai: json['ai'] != null
          ? AiSettingsModel.fromJson(json['ai'])
          : AiSettingsModel(),
      privacy: json['privacy'] != null
          ? PrivacySettingsModel.fromJson(json['privacy'])
          : PrivacySettingsModel(),
      security: json['security'] != null
          ? SecuritySettingsModel.fromJson(json['security'])
          : SecuritySettingsModel(),
      delivery: json['delivery'] != null
          ? DeliveryPreferencesModel.fromJson(json['delivery'])
          : DeliveryPreferencesModel(),
      accessibility: json['accessibility'] != null
          ? AccessibilitySettingsModel.fromJson(json['accessibility'])
          : AccessibilitySettingsModel(),
      storage: json['storage'] != null
          ? StorageSettingsModel.fromJson(json['storage'])
          : StorageSettingsModel(),
    );
  }

  Map<String, dynamic> toJson() => {
    'language': language.toJson(),
    'theme': theme.toJson(),
    'notifications': notifications.toJson(),
    'ai': ai.toJson(),
    'privacy': privacy.toJson(),
    'security': security.toJson(),
    'delivery': delivery.toJson(),
    'accessibility': accessibility.toJson(),
    'storage': storage.toJson(),
  };

  UserSettingsModel copyWith({
    LanguageModel? language,
    ThemeModel? theme,
    NotificationSettingsModel? notifications,
    AiSettingsModel? ai,
    PrivacySettingsModel? privacy,
    SecuritySettingsModel? security,
    DeliveryPreferencesModel? delivery,
    AccessibilitySettingsModel? accessibility,
    StorageSettingsModel? storage,
  }) {
    return UserSettingsModel(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      ai: ai ?? this.ai,
      privacy: privacy ?? this.privacy,
      security: security ?? this.security,
      delivery: delivery ?? this.delivery,
      accessibility: accessibility ?? this.accessibility,
      storage: storage ?? this.storage,
    );
  }
}
