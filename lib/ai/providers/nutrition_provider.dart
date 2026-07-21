import 'package:flutter/foundation.dart';
import '../models/nutrition_analysis.dart';
import '../services/nutrition_service.dart';

class NutritionProvider with ChangeNotifier {
  NutritionAnalysis? _analysis;
  List<NutritionAnalysis> _history = [];
  bool _isLoading = false;

  NutritionAnalysis? get analysis => _analysis;
  List<NutritionAnalysis> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> analyze({String? mealId, String? query}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _analysis = await NutritionService.analyze(mealId: mealId, query: query);
    } catch (e) {
      _analysis = NutritionAnalysis(suggestion: 'Unable to analyze nutrition data.');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    try {
      _history = await NutritionService.getHistory();
      notifyListeners();
    } catch (_) {}
  }

  void clear() {
    _analysis = null;
    notifyListeners();
  }
}
