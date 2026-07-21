class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final String type;
  final String categoryName;
  final String categoryId;
  final double price;
  final String unit;
  final int stock;
  final bool isAvailable;
  final bool isPopular;
  final bool isFavorite;
  final String badge;
  final int preparationTime;
  final String difficulty;
  final int servings;
  final int ingredientsCount;
  final int favoritesCount;
  final List<Ingredient> ingredients;

  Product({
    required this.id,
    required this.name,
    this.description = '',
    this.image = '',
    this.type = 'meal',
    this.categoryName = '',
    this.categoryId = '',
    this.price = 0,
    this.unit = '',
    this.stock = 0,
    this.isAvailable = true,
    this.isPopular = false,
    this.isFavorite = false,
    this.badge = '',
    this.preparationTime = 30,
    this.difficulty = 'Easy',
    this.servings = 2,
    this.ingredientsCount = 0,
    this.favoritesCount = 0,
    this.ingredients = const [],
  });

  int get cookTime => preparationTime;
  int get serves => servings;
  int get ingredientCount => ingredientsCount;

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['categoryId'];
    String catName = json['categoryName'] ?? '';
    if (category is Map<String, dynamic>) {
      catName = category['name'] ?? '';
    }

    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? 'meal',
      categoryName: catName,
      categoryId: category is String ? category : (category is Map ? (category['_id'] ?? '') : ''),
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      stock: json['stock'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      isPopular: json['isPopular'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      badge: json['badge'] ?? '',
      preparationTime: json['preparationTime'] ?? 30,
      difficulty: json['difficulty'] ?? 'Easy',
      servings: json['servings'] ?? 2,
      ingredientsCount: json['ingredientsCount'] ?? 0,
      favoritesCount: json['favoritesCount'] ?? 0,
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List).map((i) => Ingredient.fromJson(i)).toList()
          : [],
    );
  }

  factory Product.fromMealJson(Map<String, dynamic> json) {
    final category = json['categoryId'];
    String catName = json['categoryName'] ?? '';
    if (category is Map<String, dynamic>) {
      catName = category['name'] ?? '';
    }
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      type: 'meal',
      categoryName: catName,
      categoryId: category is String ? category : (category is Map ? (category['_id'] ?? '') : ''),
      isPopular: json['isPopular'] ?? false,
      preparationTime: json['preparationTime'] ?? 30,
      difficulty: json['difficulty'] ?? 'Easy',
      servings: json['servings'] ?? 2,
      ingredientsCount: json['ingredientsCount'] ?? 0,
      favoritesCount: json['favoritesCount'] ?? 0,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? type,
    String? categoryName,
    String? categoryId,
    double? price,
    String? unit,
    int? stock,
    bool? isAvailable,
    bool? isPopular,
    bool? isFavorite,
    String? badge,
    int? preparationTime,
    String? difficulty,
    int? servings,
    int? ingredientsCount,
    int? favoritesCount,
    List<Ingredient>? ingredients,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      type: type ?? this.type,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      isPopular: isPopular ?? this.isPopular,
      isFavorite: isFavorite ?? this.isFavorite,
      badge: badge ?? this.badge,
      preparationTime: preparationTime ?? this.preparationTime,
      difficulty: difficulty ?? this.difficulty,
      servings: servings ?? this.servings,
      ingredientsCount: ingredientsCount ?? this.ingredientsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}

class Ingredient {
  final String name;
  final String quantity;
  final String unit;

  Ingredient({required this.name, this.quantity = '', this.unit = ''});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? (json['foodstuffId'] is Map ? json['foodstuffId']['name'] ?? '' : ''),
      quantity: json['quantity']?.toString() ?? '',
      unit: json['unit'] ?? '',
    );
  }
}
