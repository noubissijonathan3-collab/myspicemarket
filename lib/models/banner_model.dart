class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String buttonText;
  final String link;
  final String linkType;
  final String linkValue;
  final bool isActive;
  final int sortOrder;
  final String backgroundColor;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.image = '',
    this.buttonText = 'Shop Now',
    this.link = '',
    this.linkType = 'category',
    this.linkValue = '',
    this.isActive = true,
    this.sortOrder = 0,
    this.backgroundColor = '#22c55e',
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      buttonText: json['buttonText'] ?? 'Shop Now',
      link: json['link'] ?? '',
      linkType: json['linkType'] ?? 'category',
      linkValue: json['linkValue'] ?? '',
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
      backgroundColor: json['backgroundColor'] ?? '#22c55e',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'image': image,
    'buttonText': buttonText,
    'link': link,
    'linkType': linkType,
    'linkValue': linkValue,
    'isActive': isActive,
    'sortOrder': sortOrder,
    'backgroundColor': backgroundColor,
  };
}
