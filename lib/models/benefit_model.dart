class BenefitModel {
  final String id;
  final String icon;
  final String title;
  final String description;
  final int sortOrder;

  BenefitModel({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    this.sortOrder = 0,
  });

  factory BenefitModel.fromJson(Map<String, dynamic> json) {
    return BenefitModel(
      id: json['_id'] ?? json['id'] ?? '',
      icon: json['icon'] ?? 'spa',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}
