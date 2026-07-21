import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class CartService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/cart';

  static Future<Map<String, dynamic>> fetchCart() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw data['message'] ?? 'Failed to fetch cart';
  }

  static Future<Map<String, dynamic>> addToCart(String productId, {int quantity = 1}) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw data['message'] ?? 'Failed to add to cart';
  }

  static Future<Map<String, dynamic>> updateQuantity(String productId, int quantity) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw data['message'] ?? 'Failed to update cart';
  }

  static Future<void> removeFromCart(String productId) async {
    final token = await AuthService.getToken();
    await http.delete(
      Uri.parse('$baseUrl/remove/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<void> clearCart() async {
    final token = await AuthService.getToken();
    await http.delete(
      Uri.parse('$baseUrl/clear'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
