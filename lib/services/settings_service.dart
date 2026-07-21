import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/accessibility_settings_model.dart';
import '../models/ai_settings_model.dart';
import '../models/delivery_preferences_model.dart';
import '../models/language_model.dart';
import '../models/notification_settings_model.dart';
import '../models/privacy_settings_model.dart';
import '../models/security_settings_model.dart';
import '../models/theme_model.dart';
import '../models/user_settings_model.dart';
import 'auth_service.dart';

class SettingsService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/settings';

  static Future<UserSettingsModel> getSettings() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return UserSettingsModel.fromJson(data is Map ? data : data['settings'] ?? {});
    }
    throw data['message'] ?? 'Failed to fetch settings';
  }

  static Future<UserSettingsModel> updateSettings(UserSettingsModel settings) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(settings.toJson()),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return UserSettingsModel.fromJson(data is Map ? data : data['settings'] ?? {});
    }
    throw data['message'] ?? 'Failed to update settings';
  }

  static Future<void> updateTheme(ThemeModel theme) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/theme'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(theme.toJson()),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to update theme';
    }
  }

  static Future<void> updateLanguage(LanguageModel lang) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/language'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(lang.toJson()),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to update language';
    }
  }

  static Future<void> updateNotifications(NotificationSettingsModel notif) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(notif.toJson()),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to update notifications';
    }
  }

  static Future<void> updatePrivacy(PrivacySettingsModel privacy) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/privacy'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(privacy.toJson()),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to update privacy';
    }
  }

  static Future<void> updateSecurity(SecuritySettingsModel security) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/security'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(security.toJson()),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to update security';
    }
  }

  static Future<void> updateAi(AiSettingsModel ai) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/ai'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(ai.toJson()),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to update AI settings';
    }
  }

  static Future<void> updateDelivery(DeliveryPreferencesModel delivery) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/delivery'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(delivery.toJson()),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to update delivery preferences';
    }
  }

  static Future<void> updateAccessibility(AccessibilitySettingsModel acc) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/accessibility'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(acc.toJson()),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to update accessibility settings';
    }
  }

  static Future<Map<String, dynamic>> clearCache() async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/cache'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data is Map ? Map<String, dynamic>.from(data) : {};
    }
    throw data['message'] ?? 'Failed to clear cache';
  }
}
