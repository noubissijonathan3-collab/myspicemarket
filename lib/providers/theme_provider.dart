import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../services/settings_service.dart';
import '../services/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  String _themeMode = 'system';
  String _fontSize = 'medium';
  String _layout = 'comfortable';
  bool _highContrast = false;
  String _animationIntensity = 'medium';
  final bool _isLoading = false;
  String? _error;

  String get themeMode => _themeMode;
  String get fontSize => _fontSize;
  String get layout => _layout;
  bool get highContrast => _highContrast;
  String get animationIntensity => _animationIntensity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadFromSettings(ThemeModel t) {
    _themeMode = t.mode;
    _fontSize = t.fontSize;
    _layout = t.layout;
    _highContrast = t.highContrast;
    _animationIntensity = t.animationIntensity;
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    _error = null;
    notifyListeners();
    try {
      await ThemeService.applyTheme(mode);
      await _saveTheme();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setFontSize(String size) async {
    _fontSize = size;
    _error = null;
    notifyListeners();
    try {
      await _saveTheme();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setLayout(String l) async {
    _layout = l;
    _error = null;
    notifyListeners();
    try {
      await _saveTheme();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setHighContrast(bool v) async {
    _highContrast = v;
    _error = null;
    notifyListeners();
    try {
      await _saveTheme();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setAnimationIntensity(String v) async {
    _animationIntensity = v;
    _error = null;
    notifyListeners();
    try {
      await _saveTheme();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _saveTheme() async {
    await SettingsService.updateTheme(ThemeModel(
      mode: _themeMode,
      fontSize: _fontSize,
      layout: _layout,
      highContrast: _highContrast,
      animationIntensity: _animationIntensity,
    ));
  }
}
