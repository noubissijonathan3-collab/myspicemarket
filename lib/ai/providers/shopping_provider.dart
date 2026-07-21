import 'package:flutter/foundation.dart';
import '../models/shopping_plan.dart';
import '../services/shopping_assistant_service.dart';

class ShoppingProvider with ChangeNotifier {
  BudgetPlan? _budgetPlan;
  WeeklyMealPlan? _weeklyPlan;
  bool _isLoading = false;

  BudgetPlan? get budgetPlan => _budgetPlan;
  WeeklyMealPlan? get weeklyPlan => _weeklyPlan;
  bool get isLoading => _isLoading;

  Future<void> planBudget(double budget) async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgetPlan = await ShoppingAssistantService.planBudget(budget);
    } catch (_) {
      _budgetPlan = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> generateWeeklyPlan({int familySize = 1, double budget = 0, List<String> preferences = const []}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _weeklyPlan = await ShoppingAssistantService.generateWeeklyPlan(familySize: familySize, budget: budget, preferences: preferences);
    } catch (_) {
      _weeklyPlan = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _budgetPlan = null;
    _weeklyPlan = null;
    notifyListeners();
  }
}
