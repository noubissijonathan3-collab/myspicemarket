import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/ai_settings_model.dart';
import 'auth_service.dart';
import 'settings_service.dart';

class AiSettingsService {
  static Future<void> updateAiSettings(AiSettingsModel settings) async {
    await SettingsService.updateAi(settings);
  }

  static Future<void> clearAiHistory() async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/api/ai/conversations'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to clear AI history';
    }
  }

  static Future<void> resetAiLearning() async {
    // Placeholder for resetting AI learning data
  }
}
