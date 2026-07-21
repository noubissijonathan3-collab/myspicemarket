import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/auth';

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fullName': fullName, 'email': email, 'phone': phone, 'password': password}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      await _saveToken(data['token']);
      await _saveUser(data['user']);
      return data;
    }
    throw data['message'] ?? 'Registration failed';
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await _saveToken(data['token']);
      await _saveUser(data['user']);
      return data;
    }
    throw data['message'] ?? 'Login failed';
  }

  static Future<User?> getProfile() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'] is Map ? data['user'] as Map<String, dynamic> : data;
        final user = User.fromJson(userData);
        await _saveUser(userData);
        return user;
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
    return await _loadSavedUser();
  }

  static Future<void> updateProfile(Map<String, dynamic> updates) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updates),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveUser(data['user'] is Map ? data['user'] as Map<String, dynamic> : data);
    } else {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to update profile';
    }
  }

  static Future<String> uploadAvatar(Uint8List imageBytes) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final base64Image = base64Encode(imageBytes);

    final prefs = await SharedPreferences.getInstance();
    final savedRaw = prefs.getString('user_data');
    if (savedRaw == null) throw Exception('No saved user data');
    final saved = jsonDecode(savedRaw) as Map<String, dynamic>;
    final fullName = saved['fullName'] as String? ?? '';

    final response = await http.put(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'avatar': base64Image,
        'fullName': fullName,
      }),
    ).timeout(const Duration(seconds: 30));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final userData = data['user'] is Map ? data['user'] as Map<String, dynamic> : data;
      await _saveUser(userData);
      final avatarUrl = (userData['avatar'] ?? userData['profileImage'] ?? '') as String;
      return avatarUrl.startsWith('http') ? avatarUrl : '${AppConfig.baseUrl}$avatarUrl';
    }
    throw Exception('${response.statusCode}: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  static Future<User?> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    if (data != null) {
      return User.fromJson(jsonDecode(data));
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, dynamic>> findAccount(String identifier) async {
    final response = await http.post(
      Uri.parse('$baseUrl/find-account'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw data['message'] ?? 'Account not found';
  }

  static Future<void> forgotPassword(String identifier, String method) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'method': method}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw data['message'] ?? 'Failed to send code';
  }

  static Future<void> sendVerificationOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-verification-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw data['message'] ?? 'Failed to send verification code';
  }

  static Future<void> verifyOTP(String identifier, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'otp': otp}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw data['message'] ?? 'Invalid OTP';
  }

  static Future<void> resetPassword(String identifier, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': newPassword}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw data['message'] ?? 'Reset failed';
  }
}
