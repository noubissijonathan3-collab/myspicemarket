import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../models/shopping_plan.dart';

class BudgetService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/ai/shopping';

  static Future<BudgetPlan> createPlan(double budget) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/budget'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'budget': budget}),
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode == 200) return BudgetPlan.fromJson(jsonDecode(res.body));
    throw Exception('Failed to create budget plan');
  }
}
