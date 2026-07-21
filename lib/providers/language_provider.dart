import 'package:flutter/material.dart';
import '../models/language_model.dart';
import '../services/language_service.dart';
import '../services/settings_service.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en';
  bool _autoDetect = true;
  bool _translateDynamic = true;
  bool _translateChat = false;
  List<LanguageModel> _languages = [];
  bool _isLoading = false;
  String? _error;

  String get currentLanguage => _currentLanguage;
  bool get autoDetect => _autoDetect;
  bool get translateDynamic => _translateDynamic;
  bool get translateChat => _translateChat;
  List<LanguageModel> get languages => _languages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadFromSettings(LanguageModel l) {
    _currentLanguage = l.code;
    _autoDetect = l.autoDetect;
    _translateDynamic = l.translateDynamic;
    _translateChat = l.translateChat;
    notifyListeners();
  }

  Future<void> loadLanguages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _languages = await LanguageService.getLanguages();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _currentLanguage = code;
    _error = null;
    notifyListeners();
    try {
      await LanguageService.setLanguage(code);
      await _saveLanguage();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setAutoDetect(bool v) async {
    _autoDetect = v;
    _error = null;
    notifyListeners();
    try {
      await _saveLanguage();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setTranslateDynamic(bool v) async {
    _translateDynamic = v;
    _error = null;
    notifyListeners();
    try {
      await _saveLanguage();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setTranslateChat(bool v) async {
    _translateChat = v;
    _error = null;
    notifyListeners();
    try {
      await _saveLanguage();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _saveLanguage() async {
    await SettingsService.updateLanguage(LanguageModel(
      code: _currentLanguage,
      name: '',
      nativeName: '',
      autoDetect: _autoDetect,
      translateDynamic: _translateDynamic,
      translateChat: _translateChat,
    ));
  }
}
