import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../models/language_model.dart';

class TranslationService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/ai/translate';
  static const String _langKey = 'app_language';
  static const String _translateContentKey = 'translate_dynamic_content';
  static const String _translateChatKey = 'translate_chat';

  static Future<String> translate(String text, String targetLanguage, {String sourceLanguage = 'en', String contextType = 'meal'}) async {
    if (text.isEmpty || targetLanguage == sourceLanguage) return text;

    final token = await AuthService.getToken();
    if (token == null) return text;

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/translate'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'text': text, 'targetLanguage': targetLanguage, 'sourceLanguage': sourceLanguage, 'contextType': contextType}),
      ).timeout(const Duration(seconds: 60));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['translatedText'] ?? text;
      }
    } catch (_) {}

    return text;
  }

  static Future<List<Language>> getLanguages() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/languages'),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Language.fromJson(e)).toList();
    }
    return [];
  }

  static Future<String> getAppLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'en';
  }

  static Future<void> setAppLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  static Future<bool> shouldTranslateContent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_translateContentKey) ?? false;
  }

  static Future<void> setTranslateContent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_translateContentKey, value);
  }

  static Future<bool> shouldTranslateChat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_translateChatKey) ?? false;
  }

  static Future<void> setTranslateChat(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_translateChatKey, value);
  }
}
