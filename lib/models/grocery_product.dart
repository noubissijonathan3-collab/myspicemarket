class GroceryProduct {
  final String id;
  final String name;
  final String description;
  final String image;
  final String category;
  final int price;
  final int stock;
  final String unit;
  final bool isAvailable;
  final bool isFavorite;

  GroceryProduct({
    required this.id,
    required this.name,
    this.description = '',
    this.image = '',
    this.category = 'Other',
    required this.price,
    this.stock = 0,
    this.unit = 'piece',
    this.isAvailable = true,
    this.isFavorite = false,
  });

  factory GroceryProduct.fromJson(Map<String, dynamic> json) {
    return GroceryProduct(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? 'Other',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? 'piece',
      isAvailable: json['isAvailable'] ?? true,
      isFavorite: json['isFavorite'] ?? json['liked'] ?? false,
    );
  }

  GroceryProduct copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? category,
    int? price,
    int? stock,
    String? unit,
    bool? isAvailable,
    bool? isFavorite,
  }) {
    return GroceryProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
