class SeasonalCollectionModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<String> productIds;
  final String theme;
  final int sortOrder;

  SeasonalCollectionModel({
    required this.id,
    required this.name,
    this.description = '',
    this.image = '',
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.productIds = const [],
    this.theme = '',
    this.sortOrder = 0,
  });

  bool get isCurrentlyActive {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return isActive;
  }

  factory SeasonalCollectionModel.fromJson(Map<String, dynamic> json) {
    return SeasonalCollectionModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? true,
      productIds: (json['products'] as List?)?.map((e) => e.toString()).toList() ?? [],
      theme: json['theme'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'image': image,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isActive': isActive,
    'products': productIds,
    'theme': theme,
    'sortOrder': sortOrder,
  };
}
