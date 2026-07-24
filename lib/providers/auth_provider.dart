import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/notification_model.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/call_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  StreamController<NotificationModel>? _notificationStreamController;
  StreamController<int>? _unreadCountStreamController;

  Stream<NotificationModel> get notificationStream => _notificationStreamController?.stream ?? const Stream.empty();
  Stream<int> get unreadCountStream => _unreadCountStreamController?.stream ?? const Stream.empty();

  void _setupNotificationListeners() {
    _notificationStreamController = StreamController<NotificationModel>.broadcast();
    _unreadCountStreamController = StreamController<int>.broadcast();

    ChatService.onNotificationReceived = (data) {
      final notif = NotificationModel.fromJson(data);
      _notificationStreamController?.add(notif);
    };

    ChatService.onUnreadCountChanged = (count) {
      _unreadCountStreamController?.add(count);
    };
  }

  void _teardownNotificationListeners() {
    ChatService.onNotificationReceived = null;
    ChatService.onUnreadCountChanged = null;
    _notificationStreamController?.close();
    _notificationStreamController = null;
    _unreadCountStreamController?.close();
    _unreadCountStreamController = null;
  }

  Future<void> loadProfile() async {
    try {
      _user = await AuthService.getProfile();
      if (_user != null) {
        ChatService.connect();
        CallService.connect();
        _setupNotificationListeners();
      }
      notifyListeners();
    } catch (_) {
      _user = null;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AuthService.login(email: email, password: password);
      _user = User.fromJson(data['user']);
      ChatService.connect();
      CallService.connect();
      _setupNotificationListeners();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AuthService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      _user = User.fromJson(data['user'] as Map<String, dynamic>);
      ChatService.connect();
      CallService.connect();
      _setupNotificationListeners();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    ChatService.disconnect();
    _teardownNotificationListeners();
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
