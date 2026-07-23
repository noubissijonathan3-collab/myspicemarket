import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/recommendation_model.dart';
import 'auth_service.dart';

class RecommendationService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/recommendations';

  static Future<List<RecommendationModel>> fetchRecommendations() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List list = data is List ? data : (data['recommendations'] ?? []);
      return list.map((e) => RecommendationModel.fromJson(e)).toList();
    }
    throw data['message'] ?? 'Failed to fetch recommendations';
  }

  static Future<void> generateRecommendations() async {
    final token = await AuthService.getToken();
    await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
