import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class LocationService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/location';

  static Future<Map<String, dynamic>> reverseGeocode(double lat, double lng) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reverse-geocode?lat=$lat&lng=$lng'),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw data['message'] ?? 'Failed to reverse geocode';
  }

  static Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List list = data is List ? data : (data['predictions'] ?? data['results'] ?? []);
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    throw data['message'] ?? 'Failed to search location';
  }

  static Future<Map<String, dynamic>> getDeliveryEstimate(double lat, double lng) async {
    final response = await http.get(
      Uri.parse('$baseUrl/delivery-estimate?lat=$lat&lng=$lng'),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw data['message'] ?? 'Failed to get delivery estimate';
  }
}
