class NutritionAnalysis {
  final String meal;
  final int calories;
  final String protein;
  final String carbs;
  final String fat;
  final String fiber;
  final String summary;
  final String suggestion;
  final String note;

  NutritionAnalysis({
    this.meal = '',
    this.calories = 0,
    this.protein = '',
    this.carbs = '',
    this.fat = '',
    this.fiber = '',
    this.summary = '',
    this.suggestion = '',
    this.note = '',
  });

  factory NutritionAnalysis.fromJson(Map<String, dynamic> json) => NutritionAnalysis(
    meal: json['meal'] ?? '',
    calories: json['calories'] ?? 0,
    protein: json['protein']?.toString() ?? '',
    carbs: json['carbs']?.toString() ?? '',
    fat: json['fat']?.toString() ?? '',
    fiber: json['fiber']?.toString() ?? '',
    summary: json['summary'] ?? '',
    suggestion: json['suggestion'] ?? '',
    note: json['note'] ?? '',
  );
}
