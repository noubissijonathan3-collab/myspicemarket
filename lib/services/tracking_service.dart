import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class TrackingService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/tracking';

  static Future<Map<String, dynamic>?> getAgentLocation(String agentId) async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    final res = await http.get(
      Uri.parse('$_baseUrl/agent/$agentId'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data == null || data is! Map<String, dynamic>) return null;
      return data;
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getOrderLocationHistory(String orderId) async {
    final token = await AuthService.getToken();
    if (token == null) return [];
    final res = await http.get(
      Uri.parse('$_baseUrl/order/$orderId'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<List<dynamic>> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) return [];
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/route?startLat=$startLat&startLng=$startLng&endLat=$endLat&endLng=$endLng'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final features = data['features'];
        if (features is List && features.isNotEmpty) {
          final geometry = features[0]['geometry'];
          if (geometry != null && geometry['coordinates'] is List) {
            return geometry['coordinates'];
          }
        }
      }
    } catch (_) {}
    return [];
  }
}
