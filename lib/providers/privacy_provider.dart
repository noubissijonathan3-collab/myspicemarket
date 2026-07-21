import 'package:flutter/material.dart';
import '../models/privacy_settings_model.dart';
import '../services/privacy_service.dart';

class PrivacyProvider with ChangeNotifier {
  bool _dataSharing = false;
  bool _analytics = true;
  bool _cookieConsent = false;
  final bool _isLoading = false;
  String? _error;

  bool get dataSharing => _dataSharing;
  bool get analytics => _analytics;
  bool get cookieConsent => _cookieConsent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadFromSettings(PrivacySettingsModel p) {
    _dataSharing = p.dataSharing;
    _analytics = p.analytics;
    _cookieConsent = p.cookieConsent;
    notifyListeners();
  }

  Future<void> setDataSharing(bool v) async {
    _dataSharing = v;
    notifyListeners();
    await _save();
  }

  Future<void> setAnalytics(bool v) async {
    _analytics = v;
    notifyListeners();
    await _save();
  }

  Future<void> setCookieConsent(bool v) async {
    _cookieConsent = v;
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    _error = null;
    try {
      await PrivacyService.updatePrivacySettings(PrivacySettingsModel(
        dataSharing: _dataSharing,
        analytics: _analytics,
        cookieConsent: _cookieConsent,
      ));
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
