import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/grocery_product.dart';

class GroceryService {
  static const String baseUrl = "${AppConfig.baseUrl}/api/foodstuffs";

  static Future<Map<String, dynamic>> fetchProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (category != null && category != 'All') params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load foodstuffs');
  }

  static Future<List<GroceryProduct>> fetchByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/category/$category'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => GroceryProduct.fromJson(e)).toList();
    }
    throw Exception('Failed to load category');
  }

  static Future<GroceryProduct> fetchById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return GroceryProduct.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load product');
  }

  static Future<GroceryProduct> toggleFavorite(String productId, bool liked) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('grocery_favorites') ?? [];

    if (liked) {
      if (!favs.contains(productId)) favs.add(productId);
    } else {
      favs.remove(productId);
    }

    await prefs.setStringList('grocery_favorites', favs);
    return GroceryProduct(id: productId, name: '', price: 0, isFavorite: liked);
  }
}
