import 'package:flutter/material.dart';
import '../models/ai_settings_model.dart';
import '../services/settings_service.dart';

class AiSettingsProvider with ChangeNotifier {
  bool _cookingAssistant = true;
  bool _smartSearch = true;
  bool _recommendations = true;
  bool _ingredientSubstitutes = true;
  bool _budgetPlanner = true;
  bool _weeklyPlanner = true;
  bool _nutritionAdvisor = true;
  bool _voiceAssistant = false;
  bool _shoppingChatbot = true;
  bool _useOrderHistory = true;
  bool _useFavorites = true;
  bool _useBrowsing = true;
  bool _useSearchHistory = true;
  String _responseLanguage = 'english';
  String _responseLength = 'medium';
  bool _voiceResponses = false;
  bool _isLoading = false;
  String? _error;

  bool get cookingAssistant => _cookingAssistant;
  bool get smartSearch => _smartSearch;
  bool get recommendations => _recommendations;
  bool get ingredientSubstitutes => _ingredientSubstitutes;
  bool get budgetPlanner => _budgetPlanner;
  bool get weeklyPlanner => _weeklyPlanner;
  bool get nutritionAdvisor => _nutritionAdvisor;
  bool get voiceAssistant => _voiceAssistant;
  bool get shoppingChatbot => _shoppingChatbot;
  bool get useOrderHistory => _useOrderHistory;
  bool get useFavorites => _useFavorites;
  bool get useBrowsing => _useBrowsing;
  bool get useSearchHistory => _useSearchHistory;
  String get responseLanguage => _responseLanguage;
  String get responseLength => _responseLength;
  bool get voiceResponses => _voiceResponses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadFromSettings(AiSettingsModel a) {
    _cookingAssistant = a.cookingAssistant;
    _smartSearch = a.smartSearch;
    _recommendations = a.recommendations;
    _ingredientSubstitutes = a.ingredientSubstitutes;
    _budgetPlanner = a.budgetPlanner;
    _weeklyPlanner = a.weeklyPlanner;
    _nutritionAdvisor = a.nutritionAdvisor;
    _voiceAssistant = a.voiceAssistant;
    _shoppingChatbot = a.shoppingChatbot;
    _useOrderHistory = a.useOrderHistory;
    _useFavorites = a.useFavorites;
    _useBrowsing = a.useBrowsing;
    _useSearchHistory = a.useSearchHistory;
    _responseLanguage = a.responseLanguage;
    _responseLength = a.responseLength;
    _voiceResponses = a.voiceResponses;
    notifyListeners();
  }

  AiSettingsModel _buildModel() {
    return AiSettingsModel(
      cookingAssistant: _cookingAssistant,
      smartSearch: _smartSearch,
      recommendations: _recommendations,
      ingredientSubstitutes: _ingredientSubstitutes,
      budgetPlanner: _budgetPlanner,
      weeklyPlanner: _weeklyPlanner,
      nutritionAdvisor: _nutritionAdvisor,
      voiceAssistant: _voiceAssistant,
      shoppingChatbot: _shoppingChatbot,
      useOrderHistory: _useOrderHistory,
      useFavorites: _useFavorites,
      useBrowsing: _useBrowsing,
      useSearchHistory: _useSearchHistory,
      responseLanguage: _responseLanguage,
      responseLength: _responseLength,
      voiceResponses: _voiceResponses,
    );
  }

  Future<void> setCookingAssistant(bool v) async { _cookingAssistant = v; _notifyAndSave(); }
  Future<void> setSmartSearch(bool v) async { _smartSearch = v; _notifyAndSave(); }
  Future<void> setRecommendations(bool v) async { _recommendations = v; _notifyAndSave(); }
  Future<void> setIngredientSubstitutes(bool v) async { _ingredientSubstitutes = v; _notifyAndSave(); }
  Future<void> setBudgetPlanner(bool v) async { _budgetPlanner = v; _notifyAndSave(); }
  Future<void> setWeeklyPlanner(bool v) async { _weeklyPlanner = v; _notifyAndSave(); }
  Future<void> setNutritionAdvisor(bool v) async { _nutritionAdvisor = v; _notifyAndSave(); }
  Future<void> setVoiceAssistant(bool v) async { _voiceAssistant = v; _notifyAndSave(); }
  Future<void> setShoppingChatbot(bool v) async { _shoppingChatbot = v; _notifyAndSave(); }
  Future<void> setUseOrderHistory(bool v) async { _useOrderHistory = v; _notifyAndSave(); }
  Future<void> setUseFavorites(bool v) async { _useFavorites = v; _notifyAndSave(); }
  Future<void> setUseBrowsing(bool v) async { _useBrowsing = v; _notifyAndSave(); }
  Future<void> setUseSearchHistory(bool v) async { _useSearchHistory = v; _notifyAndSave(); }
  Future<void> setResponseLanguage(String v) async { _responseLanguage = v; _notifyAndSave(); }
  Future<void> setResponseLength(String v) async { _responseLength = v; _notifyAndSave(); }
  Future<void> setVoiceResponses(bool v) async { _voiceResponses = v; _notifyAndSave(); }

  void _notifyAndSave() {
    notifyListeners();
    _error = null;
    _save();
  }

  Future<void> _save() async {
    try {
      await SettingsService.updateAi(_buildModel());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await SettingsService.clearCache();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetLearning() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await SettingsService.clearCache();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
