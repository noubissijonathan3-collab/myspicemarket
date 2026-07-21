import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/product.dart';
import '../models/meal_ingredient.dart';
import '../models/review.dart';
import '../models/grocery_product.dart';

class MealDetailService {
  static const String _mealsUrl = "${AppConfig.baseUrl}/api/meals";
  static const String _reviewsUrl = "${AppConfig.baseUrl}/api/reviews";
  static const String _foodstuffsUrl = "${AppConfig.baseUrl}/api/foodstuffs";
  static const String _settingsUrl = "${AppConfig.baseUrl}/api/settings";

  static Future<Product> fetchMeal(String id) async {
    final response = await http.get(Uri.parse("$_mealsUrl/$id"));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception("Failed to load meal");
  }

  static Future<List<MealIngredient>> fetchIngredients(String mealId) async {
    final response = await http.get(Uri.parse("$_mealsUrl/$mealId/ingredients"));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => MealIngredient.fromJson(e)).toList();
    }
    throw Exception("Failed to load ingredients");
  }

  static Future<List<Review>> fetchReviews(String mealId) async {
    final response = await http.get(Uri.parse("$_reviewsUrl/meal/$mealId"));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Review.fromJson(e)).toList();
    }
    throw Exception("Failed to load reviews");
  }

  static Future<List<GroceryProduct>> fetchRecommendedProducts() async {
    final response = await http.get(Uri.parse("$_foodstuffsUrl?limit=6"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List products = data['products'] ?? [];
      return products.map((e) => GroceryProduct.fromJson(e)).toList();
    }
    throw Exception("Failed to load recommendations");
  }

  static Future<List<Product>> fetchRelatedMeals(String categoryId) async {
    final response = await http.get(
      Uri.parse("$_mealsUrl?categoryId=$categoryId"),
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception("Failed to load related meals");
  }

  static Future<int> fetchDeliveryFee() async {
    try {
      final response = await http.get(Uri.parse(_settingsUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['deliveryFee'] ?? 1500;
      }
    } catch (_) {}
    return 1500;
  }

  static Future<bool> toggleFavorite({
    required String mealId,
    required bool isFavorite,
    required String? token,
  }) async {
    try {
      if (isFavorite) {
        await http.delete(
          Uri.parse("${AppConfig.baseUrl}/api/favorites/$mealId"),
          headers: {
            if (token != null) "Authorization": "Bearer $token",
          },
        );
      } else {
        await http.post(
          Uri.parse("${AppConfig.baseUrl}/api/favorites"),
          headers: {
            "Content-Type": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
          body: json.encode({"mealId": mealId}),
        );
      }
      return !isFavorite;
    } catch (_) {
      return isFavorite;
    }
  }
}
