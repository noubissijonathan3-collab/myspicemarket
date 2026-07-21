import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String get userName => _user?.fullName ?? 'Jonathan';
  String get firstName => _user?.firstName ?? 'Jonathan';

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await AuthService.getProfile();
    } catch (_) {
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      await AuthService.updateProfile(updates);
      await loadProfile();
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      await loadProfile();
      return _user != null;
    }
    return false;
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
