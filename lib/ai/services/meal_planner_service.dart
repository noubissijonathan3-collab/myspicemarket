import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../models/shopping_plan.dart';

class MealPlannerService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/ai/shopping';

  static Future<WeeklyMealPlan> generatePlan({
    required int familySize,
    required double budget,
    List<String> preferences = const [],
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/weekly-plan'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'familySize': familySize, 'budget': budget, 'preferences': preferences}),
    ).timeout(const Duration(seconds: 30));

    if (res.statusCode == 200) return WeeklyMealPlan.fromJson(jsonDecode(res.body));
    throw Exception('Failed to generate meal plan');
  }
}
