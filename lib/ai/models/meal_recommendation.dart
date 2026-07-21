class MealRecommendation {
  final String mealId;
  final String name;
  final String image;
  final String description;
  final double price;
  final String reason;
  final int score;
  final int preparationTime;
  final int servings;

  MealRecommendation({
    required this.mealId,
    required this.name,
    this.image = '',
    this.description = '',
    this.price = 0,
    this.reason = '',
    this.score = 0,
    this.preparationTime = 0,
    this.servings = 1,
  });

  factory MealRecommendation.fromJson(Map<String, dynamic> json) {
    final meal = json['meal'] as Map<String, dynamic>?;
    return MealRecommendation(
      mealId: meal?['_id'] ?? json['mealId'] ?? '',
      name: meal?['name'] ?? json['name'] ?? '',
      image: meal?['image'] ?? json['image'] ?? '',
      description: meal?['description'] ?? json['description'] ?? '',
      price: (meal?['price'] ?? json['price'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      score: json['score'] ?? 0,
      preparationTime: meal?['preparationTime'] ?? json['preparationTime'] ?? 0,
      servings: meal?['servings'] ?? json['servings'] ?? 1,
    );
  }
}
