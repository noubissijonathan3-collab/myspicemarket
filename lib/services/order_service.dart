import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class OrderService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/orders';

  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return (data as List).cast<Map<String, dynamic>>();
    }
    throw data['message'] ?? 'Failed to fetch orders';
  }

  static Future<Map<String, dynamic>> fetchOrderById(String id) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw data['message'] ?? 'Failed to fetch order';
  }

  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? delivery,
  }) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'items': items, 'delivery': delivery ?? {}}),
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) return data;
    throw data['message'] ?? 'Failed to create order';
  }
}
