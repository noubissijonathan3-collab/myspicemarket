import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/product.dart';
import 'auth_service.dart';

class RecentlyViewedService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/recently-viewed';

  static Future<List<Product>> fetchRecentlyViewed() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List list = data is List ? data : (data['items'] ?? []);
      return list.map((e) {
        final product = e is Map ? e['product'] ?? e : e;
        return Product.fromJson(product is Map ? Map<String, dynamic>.from(product) : {});
      }).toList();
    }
    throw data['message'] ?? 'Failed to fetch recently viewed';
  }

  static Future<void> addRecentlyViewed(String productId, String type) async {
    final token = await AuthService.getToken();
    await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId, 'type': type}),
    ).timeout(const Duration(seconds: 10));
  }

  static Future<void> clear() async {
    final token = await AuthService.getToken();
    await http.delete(
      Uri.parse('$baseUrl/clear'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
