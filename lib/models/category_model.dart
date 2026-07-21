class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final String type;
  final int sortOrder;
  final bool isActive;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.image = '',
    this.description = '',
    this.type = 'both',
    this.sortOrder = 0,
    this.isActive = true,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'both',
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      productCount: json['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'description': description,
    'type': type,
    'sortOrder': sortOrder,
    'isActive': isActive,
  };
}
