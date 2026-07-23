import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../models/ingredient_substitute.dart';

class IngredientService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/ai/meals';

  static Future<List<IngredientSubstitute>> findSubstitutes(String ingredient) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/substitute'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'ingredient': ingredient}),
    ).timeout(const Duration(seconds: 60));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['substitutes'] as List).map((e) => IngredientSubstitute.fromJson(e)).toList();
    }
    throw Exception('Failed to find substitutes');
  }
}
