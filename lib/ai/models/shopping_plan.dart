class ShoppingPlanItem {
  final String name;
  final String quantity;
  final String unit;

  ShoppingPlanItem({required this.name, this.quantity = '', this.unit = ''});

  factory ShoppingPlanItem.fromJson(Map<String, dynamic> json) => ShoppingPlanItem(
    name: json['name'] ?? '',
    quantity: json['quantity']?.toString() ?? '',
    unit: json['unit'] ?? '',
  );
}

class WeeklyMealPlan {
  final String id;
  final int familySize;
  final double budget;
  final List<String> preferences;
  final List<DayPlan> days;
  final List<ShoppingPlanItem> shoppingList;

  WeeklyMealPlan({
    this.id = '',
    this.familySize = 1,
    this.budget = 0,
    this.preferences = const [],
    this.days = const [],
    this.shoppingList = const [],
  });

  factory WeeklyMealPlan.fromJson(Map<String, dynamic> json) => WeeklyMealPlan(
    id: json['_id'] ?? json['id'] ?? '',
    familySize: json['familySize'] ?? 1,
    budget: (json['budget'] ?? 0).toDouble(),
    preferences: List<String>.from(json['preferences'] ?? []),
    days: (json['days'] as List?)?.map((e) => DayPlan.fromJson(e)).toList() ?? [],
    shoppingList: (json['shoppingList'] as List?)?.map((e) => ShoppingPlanItem.fromJson(e)).toList() ?? [],
  );
}

class DayPlan {
  final String day;
  final List<DayMeal> meals;

  DayPlan({required this.day, this.meals = const []});

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
    day: json['day'] ?? '',
    meals: (json['meals'] as List?)?.map((e) => DayMeal.fromJson(e)).toList() ?? [],
  );
}

class DayMeal {
  final String mealId;
  final String name;
  final int servings;

  DayMeal({this.mealId = '', this.name = '', this.servings = 1});

  factory DayMeal.fromJson(Map<String, dynamic> json) => DayMeal(
    mealId: json['mealId'] ?? '',
    name: json['name'] ?? '',
    servings: json['servings'] ?? 1,
  );
}

class BudgetPlan {
  final String id;
  final double budget;
  final List<BudgetRecommendation> recommendations;
  final double totalCost;
  final double savings;

  BudgetPlan({
    this.id = '',
    this.budget = 0,
    this.recommendations = const [],
    this.totalCost = 0,
    this.savings = 0,
  });

  factory BudgetPlan.fromJson(Map<String, dynamic> json) => BudgetPlan(
    id: json['_id'] ?? json['id'] ?? '',
    budget: (json['budget'] ?? 0).toDouble(),
    recommendations: (json['recommendations'] as List?)?.map((e) => BudgetRecommendation.fromJson(e)).toList() ?? [],
    totalCost: (json['totalCost'] ?? 0).toDouble(),
    savings: (json['savings'] ?? 0).toDouble(),
  );
}

class BudgetRecommendation {
  final String mealId;
  final String name;
  final double price;
  final String reason;

  BudgetRecommendation({this.mealId = '', this.name = '', this.price = 0, this.reason = ''});

  factory BudgetRecommendation.fromJson(Map<String, dynamic> json) => BudgetRecommendation(
    mealId: json['mealId'] ?? '',
    name: json['name'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    reason: json['reason'] ?? '',
  );
}
