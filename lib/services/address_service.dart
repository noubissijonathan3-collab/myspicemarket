import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/address_model.dart';
import 'auth_service.dart';

class AddressService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/address';

  static Future<List<AddressModel>> fetchAddresses() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List list = data is List ? data : (data['addresses'] ?? []);
      return list.map((e) => AddressModel.fromJson(e)).toList();
    }
    throw data['message'] ?? 'Failed to fetch addresses';
  }

  static Future<AddressModel?> fetchDefaultAddress() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/default'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      if (data != null && data is Map && data.isNotEmpty) {
        return AddressModel.fromJson(Map<String, dynamic>.from(data));
      }
    }
    return null;
  }

  static Future<AddressModel> createAddress(AddressModel address) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(address.toJson()),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) return AddressModel.fromJson(data);
    throw data['message'] ?? 'Failed to create address';
  }

  static Future<AddressModel> updateAddress(String id, AddressModel address) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(address.toJson()),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return AddressModel.fromJson(data);
    throw data['message'] ?? 'Failed to update address';
  }

  static Future<void> deleteAddress(String id) async {
    final token = await AuthService.getToken();
    await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
