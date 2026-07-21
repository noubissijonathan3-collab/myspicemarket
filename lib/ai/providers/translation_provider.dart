import 'package:flutter/foundation.dart';
import '../models/language_model.dart';
import '../services/translation_service.dart';

class TranslationProvider with ChangeNotifier {
  String _currentLanguage = 'en';
  bool _translateDynamicContent = false;
  bool _translateChat = false;
  List<Language> _languages = [];
  bool _isLoading = false;

  String get currentLanguage => _currentLanguage;
  bool get translateDynamicContent => _translateDynamicContent;
  bool get translateChat => _translateChat;
  List<Language> get languages => _languages;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentLanguage = await TranslationService.getAppLanguage();
      _translateDynamicContent = await TranslationService.shouldTranslateContent();
      _translateChat = await TranslationService.shouldTranslateChat();
      _languages = await TranslationService.getLanguages();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _currentLanguage = code;
    await TranslationService.setAppLanguage(code);
    notifyListeners();
  }

  Future<void> setTranslateContent(bool value) async {
    _translateDynamicContent = value;
    await TranslationService.setTranslateContent(value);
    notifyListeners();
  }

  Future<void> setTranslateChat(bool value) async {
    _translateChat = value;
    await TranslationService.setTranslateChat(value);
    notifyListeners();
  }
}
