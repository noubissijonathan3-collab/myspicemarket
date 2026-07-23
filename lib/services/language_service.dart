import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/language_model.dart';
import 'auth_service.dart';

class LanguageService {
  static Future<List<LanguageModel>> getLanguages() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/languages'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data is List ? data : (data['languages'] ?? []);
        return list.map((e) => LanguageModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [
      LanguageModel(code: 'en', name: 'English', nativeName: 'English'),
      LanguageModel(code: 'es', name: 'Spanish', nativeName: 'Español'),
      LanguageModel(code: 'fr', name: 'French', nativeName: 'Français'),
      LanguageModel(code: 'de', name: 'German', nativeName: 'Deutsch'),
      LanguageModel(code: 'zh', name: 'Chinese', nativeName: '中文'),
      LanguageModel(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    ];
  }

  static Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', code);
  }
}
