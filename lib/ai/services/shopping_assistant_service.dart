import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../models/shopping_plan.dart';
import '../models/search_result.dart';

class ShoppingAssistantService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/ai/shopping';

  static Future<BudgetPlan> planBudget(double budget) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/budget'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'budget': budget}),
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode == 200) return BudgetPlan.fromJson(jsonDecode(res.body));
    throw Exception('Budget planning failed');
  }

  static Future<WeeklyMealPlan> generateWeeklyPlan({int familySize = 1, double budget = 0, List<String> preferences = const []}) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/weekly-plan'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'familySize': familySize, 'budget': budget, 'preferences': preferences}),
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode == 200) return WeeklyMealPlan.fromJson(jsonDecode(res.body));
    throw Exception('Weekly plan generation failed');
  }

  static Future<List<Map<String, String>>> getAddOns(String orderId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse('$_baseUrl/add-ons/$orderId'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<Map<String, String>>.from((data['suggestions'] as List).map((e) => {'name': e['name'] ?? '', 'reason': e['reason'] ?? ''}));
    }
    throw Exception('Failed to get suggestions');
  }

  static Future<List<SearchResult>> search(String query) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/search'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'query': query}),
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['results'] as List?)?.map((e) => SearchResult.fromJson(e)).toList() ?? [];
    }
    throw Exception('Search failed');
  }

  static Future<Map<String, dynamic>> askAssistant(String message) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/assistant'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'message': message}),
    ).timeout(const Duration(seconds: 30));

    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Assistant request failed');
  }
}
