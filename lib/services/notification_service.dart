import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/notification_model.dart';
import '../models/notification_settings_model.dart';
import 'auth_service.dart';
import 'settings_service.dart';

class NotificationService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/notifications';

  static Future<Map<String, dynamic>> fetchNotifications() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final notifications = (data['notifications'] as List).map((e) => NotificationModel.fromJson(e)).toList();
      return {'notifications': notifications, 'unreadCount': data['unreadCount'] ?? 0};
    }
    throw data['message'] ?? 'Failed to fetch notifications';
  }

  static Future<void> markAsRead(String id) async {
    final token = await AuthService.getToken();
    await http.put(
      Uri.parse('$baseUrl/$id/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<void> markAllAsRead() async {
    final token = await AuthService.getToken();
    await http.put(
      Uri.parse('$baseUrl/read-all'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<void> updateNotificationSettings(NotificationSettingsModel settings) async {
    await SettingsService.updateNotifications(settings);
  }

  static Future<void> requestPermissions() async {
    // In a real app, this would request OS notification permissions
  }
}
