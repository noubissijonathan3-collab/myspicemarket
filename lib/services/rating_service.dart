import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/rating_summary.dart';

class RatingService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/ratings';

  static Future<RatingSummary> fetchRatingSummary(String mealId) async {
    final response = await http.get(Uri.parse('$baseUrl/$mealId')).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return RatingSummary.fromJson(data);
    throw data['message'] ?? 'Failed to fetch rating summary';
  }
}
