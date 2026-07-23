import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class FavoriteService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/favorites';

  static Future<List<String>> fetchFavoriteIds() async {
    final token = await AuthService.getToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List list = data is List ? data : (data['favorites'] ?? []);
      return list.map<String>((e) {
        final item = e is Map<String, dynamic> ? e : {};
        final mealId = item['mealId'];
        if (mealId is Map) return mealId['_id']?.toString() ?? '';
        return mealId?.toString() ?? '';
      }).toList();
    }
    throw data['message'] ?? 'Failed to fetch favorites';
  }

  static Future<bool> addFavorite(String mealId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'mealId': mealId}),
    ).timeout(const Duration(seconds: 60));
    if (response.statusCode == 200 || response.statusCode == 201) return true;
    final data = _tryDecode(response.body);
    throw data['message'] ?? 'Failed to add favorite';
  }

  static Future<bool> removeFavorite(String mealId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.delete(
      Uri.parse('$baseUrl/$mealId'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    if (response.statusCode == 200 || response.statusCode == 204) return true;
    final data = _tryDecode(response.body);
    throw data['message'] ?? 'Failed to remove favorite';
  }

  static Map<String, dynamic> _tryDecode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': body.isNotEmpty ? body : 'Unknown error'};
    }
  }
}
