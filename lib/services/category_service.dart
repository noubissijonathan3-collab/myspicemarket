import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/category_model.dart';

class CategoryService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/categories';

  static Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List list = data is List ? data : (data['categories'] ?? []);
      return list.map((e) => CategoryModel.fromJson(e)).toList();
    }
    throw data['message'] ?? 'Failed to fetch categories';
  }
}
