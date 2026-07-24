import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

class NotificationService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/notifications';

  static Future<Map<String, dynamic>> fetchNotifications({
    String? category,
    bool? unreadOnly,
    int limit = 50,
    int page = 1,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw 'Not authenticated';

    final queryParams = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
    };
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (unreadOnly == true) queryParams['unreadOnly'] = 'true';

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final notifications = (data['notifications'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
      return {
        'notifications': notifications,
        'unreadCount': data['unreadCount'] ?? 0,
        'total': data['total'] ?? 0,
        'totalPages': data['totalPages'] ?? 1,
      };
    }
    throw 'Failed to fetch notifications';
  }

  static Future<int> fetchUnreadCount() async {
    final token = await AuthService.getToken();
    if (token == null) return 0;

    final response = await http.get(
      Uri.parse('$_baseUrl/unread-count'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['count'] ?? 0;
    }
    return 0;
  }

  static Future<void> markAsRead(String id) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    await http.put(
      Uri.parse('$_baseUrl/$id/read'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 30));
  }

  static Future<void> markAllAsRead({String? category}) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    await http.put(
      Uri.parse('$_baseUrl/read-all'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'category': category}),
    ).timeout(const Duration(seconds: 30));
  }

  static Future<void> deleteNotification(String id) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 30));
  }

  static Future<void> clearAll({String? category}) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final uri = category != null
        ? '$_baseUrl/clear-all?category=$category'
        : '$_baseUrl/clear-all';
    await http.delete(
      Uri.parse(uri),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 30));
  }

  static Future<void> registerFcmToken(String fcmToken, {String appType = 'customer'}) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/fcm/register'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'token': fcmToken, 'platform': 'android', 'appType': appType}),
    ).timeout(const Duration(seconds: 30));
  }
}
