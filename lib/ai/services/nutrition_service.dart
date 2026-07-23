import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../models/nutrition_analysis.dart';

class NutritionService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/ai/nutrition';

  static Future<NutritionAnalysis> analyze({String? mealId, String? query}) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final body = <String, dynamic>{};
    if (mealId != null) body['mealId'] = mealId;
    if (query != null) body['query'] = query;

    final res = await http.post(
      Uri.parse('$_baseUrl/analyze'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode == 200) return NutritionAnalysis.fromJson(jsonDecode(res.body));
    throw Exception('Nutrition analysis failed');
  }

  static Future<List<NutritionAnalysis>> getHistory() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse('$_baseUrl/history'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => NutritionAnalysis.fromJson(e)).toList();
    }
    throw Exception('Failed to load history');
  }
}
