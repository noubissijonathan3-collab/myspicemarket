import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../models/product.dart';
import '../../services/auth_service.dart';

class ChatAiService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/ai';

  static Future<Map<String, dynamic>> sendMessage(String message, {String context = 'general'}) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'message': message, 'context': context}),
    ).timeout(const Duration(seconds: 30));

    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('AI response failed');
  }

  static Future<List<Product>> suggestMeals(String query) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/meals/suggest'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'query': query}),
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final suggestions = data['suggestions'] as List? ?? [];
      return suggestions.map((e) {
        final meal = e['meal'] as Map<String, dynamic>? ?? {};
        return Product.fromMealJson(meal);
      }).toList();
    }
    throw Exception('Failed to get suggestions');
  }
}
