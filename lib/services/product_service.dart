import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/product.dart';

class ProductService {
  static String get _mealBase => '${AppConfig.baseUrl}/api/meals';
  static String get _foodstuffBase => '${AppConfig.baseUrl}/api/foodstuffs';

  static Future<Map<String, dynamic>> fetchProducts({
    String? type,
    String? category,
    int page = 1,
    int limit = 20,
    String? search,
    bool? popular,
  }) async {
    if (type == 'meal') {
      return _fetchMeals(category: category, page: page, limit: limit, search: search, popular: popular);
    }
    return _fetchFoodstuffs(category: category, page: page, limit: limit, search: search);
  }

  static Future<Map<String, dynamic>> _fetchMeals({
    String? category,
    int page = 1,
    int limit = 20,
    String? search,
    bool? popular,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (popular == true) params['popular'] = 'true';

    final uri = Uri.parse(_mealBase).replace(queryParameters: params);
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final meals = (data['meals'] as List).map((e) => Product.fromMealJson(e)).toList();
      return {
        'products': meals,
        'total': data['total'] ?? meals.length,
        'page': data['page'] ?? page,
        'pages': data['pages'] ?? 1,
      };
    }
    throw data['message'] ?? 'Failed to fetch meals';
  }

  static Future<Map<String, dynamic>> _fetchFoodstuffs({
    String? category,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (category != null && category != 'All') params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse(_foodstuffBase).replace(queryParameters: params);
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final products = (data['products'] as List).map((e) => Product.fromJson(e)).toList();
      return {
        'products': products,
        'total': data['total'] ?? 0,
        'page': data['page'] ?? page,
        'pages': data['pages'] ?? 1,
      };
    }
    throw data['message'] ?? 'Failed to fetch foodstuffs';
  }

  static Future<List<Product>> fetchPopularMeals() async {
    final response = await http.get(Uri.parse('$_mealBase/popular')).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final meals = data['meals'] as List;
      return meals.map((e) => Product.fromMealJson(e)).toList();
    }
    throw data['message'] ?? 'Failed to fetch popular meals';
  }

  static Future<List<Product>> fetchPopularGroceries() async {
    final response = await http.get(Uri.parse('$_foodstuffBase/popular')).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final items = data['products'] as List;
      return items.map((e) => Product.fromJson(e)).toList();
    }
    throw data['message'] ?? 'Failed to fetch popular groceries';
  }

  static Future<Product> fetchProductById(String id) async {
    final response = await http.get(Uri.parse('$_mealBase/$id')).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return Product.fromMealJson(data);
    throw data['message'] ?? 'Product not found';
  }

  static Future<List<Product>> searchProducts(String query) async {
    final result = await fetchProducts(search: query, limit: 10);
    return result['products'] as List<Product>;
  }
}
