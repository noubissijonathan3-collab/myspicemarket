import 'package:flutter/material.dart';
import '../models/security_settings_model.dart';
import '../services/security_service.dart';

class SecurityProvider with ChangeNotifier {
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;
  int _sessionTimeout = 30;
  List<String> _trustedDevices = [];
  bool _isLoading = false;
  String? _error;

  bool get biometricAuth => _biometricAuth;
  bool get twoFactorAuth => _twoFactorAuth;
  int get sessionTimeout => _sessionTimeout;
  List<String> get trustedDevices => _trustedDevices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadFromSettings(SecuritySettingsModel s) {
    _biometricAuth = s.biometricAuth;
    _twoFactorAuth = s.twoFactorAuth;
    _sessionTimeout = s.sessionTimeout;
    _trustedDevices = List<String>.from(s.trustedDevices);
    notifyListeners();
  }

  Future<void> setBiometricAuth(bool v) async {
    _biometricAuth = v;
    notifyListeners();
    await _save();
  }

  Future<void> setTwoFactorAuth(bool v) async {
    _twoFactorAuth = v;
    notifyListeners();
    await _save();
  }

  Future<void> setSessionTimeout(int v) async {
    _sessionTimeout = v;
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    _error = null;
    try {
      await SecurityService.updateSecuritySettings(SecuritySettingsModel(
        biometricAuth: _biometricAuth,
        twoFactorAuth: _twoFactorAuth,
        sessionTimeout: _sessionTimeout,
        trustedDevices: _trustedDevices,
      ));
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> verifyPassword(String pw) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final valid = await SecurityService.verifyPassword(pw);
      _isLoading = false;
      notifyListeners();
      return valid;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logoutAllDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await SecurityService.logoutAllDevices();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
