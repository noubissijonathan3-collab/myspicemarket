import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../models/ai_conversation.dart';

class AiService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/ai';

  static Future<Map<String, dynamic>> chat(String message, {String context = 'general'}) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'message': message, 'context': context}),
    ).timeout(const Duration(seconds: 60));

    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 401) throw Exception('Session expired. Please log in again.');
    if (res.statusCode == 429) throw Exception('Too many requests. Please wait a moment.');
    throw Exception('AI service unavailable (${res.statusCode})');
  }

  static Future<List<dynamic>> getConversations() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse('$_baseUrl/conversations'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));

    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load conversations');
  }

  static Future<AiConversation> getConversation(String id) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse('$_baseUrl/conversations/$id'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));

    if (res.statusCode == 200) {
      return AiConversation.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to load conversation');
  }

  static Future<void> deleteConversation(String id) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.delete(
      Uri.parse('$_baseUrl/conversations/$id'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));

    if (res.statusCode != 200) throw Exception('Failed to delete conversation');
  }
}
