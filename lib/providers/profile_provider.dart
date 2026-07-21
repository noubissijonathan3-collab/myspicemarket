import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class ProfileProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

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

  void clear() {
    _user = null;
    _isLoading = false;
    notifyListeners();
  }
}
