import 'package:flutter/material.dart';
import '../models/user_settings_model.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  UserSettingsModel? _settings;
  bool _isLoading = false;
  String? _error;

  UserSettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _settings = await SettingsService.getSettings();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSettings(UserSettingsModel s) async {
    _error = null;
    try {
      _settings = await SettingsService.updateSettings(s);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
