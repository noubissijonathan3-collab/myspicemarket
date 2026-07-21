class RecipeSuggestion {
  final String name;
  final String prepTime;
  final String cookTime;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tips;
  final String reason;

  RecipeSuggestion({
    this.name = '',
    this.prepTime = '',
    this.cookTime = '',
    this.ingredients = const [],
    this.steps = const [],
    this.tips = const [],
    this.reason = '',
  });

  factory RecipeSuggestion.fromJson(Map<String, dynamic> json) => RecipeSuggestion(
    name: json['name'] ?? json['meal'] ?? '',
    prepTime: json['prepTime'] ?? json['preparationTime']?.toString() ?? '',
    cookTime: json['cookTime'] ?? '',
    ingredients: List<String>.from(json['ingredients'] ?? []),
    steps: List<String>.from(json['steps'] ?? []),
    tips: List<String>.from(json['tips'] ?? []),
    reason: json['reason'] ?? '',
  );
}
