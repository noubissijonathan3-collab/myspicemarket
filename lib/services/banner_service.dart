import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/banner_model.dart';

class BannerService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/banners';

  static Future<List<BannerModel>> fetchBanners() async {
    final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List list = data is List ? data : (data['banners'] ?? []);
      return list.map((e) => BannerModel.fromJson(e)).toList();
    }
    throw data['message'] ?? 'Failed to fetch banners';
  }
}
