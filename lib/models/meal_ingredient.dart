class MealIngredient {
  final String id;
  final String mealId;
  final String foodstuffId;
  final String foodstuffName;
  final String foodstuffImage;
  final int foodstuffPrice;
  final String foodstuffUnit;
  final double quantity;
  final String unit;

  MealIngredient({
    required this.id,
    required this.mealId,
    required this.foodstuffId,
    this.foodstuffName = '',
    this.foodstuffImage = '',
    this.foodstuffPrice = 0,
    this.foodstuffUnit = 'piece',
    this.quantity = 0,
    this.unit = 'g',
  });

  factory MealIngredient.fromJson(Map<String, dynamic> json) {
    final foodstuff = json['foodstuffId'] is Map
        ? json['foodstuffId'] as Map<String, dynamic>
        : null;

    return MealIngredient(
      id: json['_id'] ?? json['id'] ?? '',
      mealId: json['mealId'] ?? '',
      foodstuffId: foodstuff != null
          ? (foodstuff['_id'] ?? foodstuff['id'] ?? '')
          : (json['foodstuffId'] ?? ''),
      foodstuffName: foodstuff?['name'] ?? '',
      foodstuffImage: foodstuff?['image'] ?? '',
      foodstuffPrice: foodstuff?['price'] ?? 0,
      foodstuffUnit: foodstuff?['unit'] ?? 'piece',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'g',
    );
  }
}
