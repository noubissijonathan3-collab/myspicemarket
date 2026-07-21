class AddressModel {
  final String id;
  final String label;
  final String street;
  final String area;
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final bool isActive;

  AddressModel({
    required this.id,
    this.label = 'Home',
    this.street = '',
    this.area = '',
    this.city = '',
    this.state = '',
    this.country = 'Cameroon',
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.isActive = true,
  });

  String get fullAddress {
    final parts = [street, area, city, state].where((p) => p.isNotEmpty);
    if (parts.isEmpty) return country;
    return '${parts.join(', ')}, $country';
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? json['id'] ?? '',
      label: json['label'] ?? 'Home',
      street: json['street'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? 'Cameroon',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'street': street,
    'area': area,
    'city': city,
    'state': state,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'isDefault': isDefault,
  };
}
