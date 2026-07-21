import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/security_settings_model.dart';
import 'auth_service.dart';
import 'settings_service.dart';

class SecurityService {
  static Future<void> updateSecuritySettings(SecuritySettingsModel settings) async {
    await SettingsService.updateSecurity(settings);
  }

  static Future<bool> verifyPassword(String password) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/auth/verify-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'password': password}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['valid'] ?? false;
    }
    throw data['message'] ?? 'Password verification failed';
  }

  static Future<void> logoutAllDevices() async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/auth/logout-all'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to logout all devices';
    }
  }
}
