import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/product.dart';

class SearchService {
  static const String baseUrl = '${AppConfig.baseUrl}/api';

  static Future<Map<String, dynamic>> search(String query) async {
    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
      'search': query,
      'limit': '10',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final products = (data['products'] as List).map((e) => Product.fromJson(e)).toList();
      return {'products': products};
    }
    throw data['message'] ?? 'Search failed';
  }

  static Future<List<Product>> searchMeals(String query) async {
    final result = await search(query);
    final products = result['products'] as List<Product>;
    return products.where((p) => p.type == 'meal').toList();
  }

  static Future<List<Product>> searchGroceries(String query) async {
    final result = await search(query);
    final products = result['products'] as List<Product>;
    return products.where((p) => p.type == 'grocery').toList();
  }
}
