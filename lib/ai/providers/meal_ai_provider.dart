import 'package:flutter/foundation.dart';
import '../models/meal_recommendation.dart';
import '../models/ingredient_substitute.dart';
import '../services/meal_ai_service.dart';

class MealAiProvider with ChangeNotifier {
  List<MealRecommendation> _suggestions = [];
  List<MealRecommendation> _recommendations = [];
  List<IngredientSubstitute> _substitutes = [];
  bool _isLoading = false;

  List<MealRecommendation> get suggestions => _suggestions;
  List<MealRecommendation> get recommendations => _recommendations;
  List<IngredientSubstitute> get substitutes => _substitutes;
  bool get isLoading => _isLoading;

  Future<void> suggestMeals(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _suggestions = await MealAiService.suggest(query);
    } catch (_) {
      _suggestions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRecommendations() async {
    try {
      _recommendations = await MealAiService.recommend();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> findSubstitutes(String ingredient) async {
    _isLoading = true;
    notifyListeners();

    try {
      _substitutes = await MealAiService.findSubstitutes(ingredient);
    } catch (_) {
      _substitutes = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
