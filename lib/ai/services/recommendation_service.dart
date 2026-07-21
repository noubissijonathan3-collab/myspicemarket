import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../models/meal_recommendation.dart';

class RecommendationService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/ai/meals';

  static Future<List<MealRecommendation>> getRecommendations() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse('$_baseUrl/recommend'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['recommendations'] as List).map((e) => MealRecommendation.fromJson(e)).toList();
    }
    throw Exception('Failed to get recommendations');
  }
}
