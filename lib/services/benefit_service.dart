import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/benefit_model.dart';

class BenefitService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/benefits';

  static Future<List<BenefitModel>> fetchBenefits() async {
    final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List list = data['benefits'] ?? [];
      return list.map((e) => BenefitModel.fromJson(e)).toList();
    }
    throw data['message'] ?? 'Failed to fetch benefits';
  }
}
