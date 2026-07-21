class LocationModel {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String street;
  final String area;
  final String city;
  final String region;
  final String country;
  final String postalCode;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.formattedAddress = '',
    this.street = '',
    this.area = '',
    this.city = '',
    this.region = '',
    this.country = 'Cameroon',
    this.postalCode = '',
  });

  factory LocationModel.fromPosition(double lat, double lng, {String address = ''}) {
    return LocationModel(latitude: lat, longitude: lng, formattedAddress: address);
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['lat'] ?? json['latitude'] ?? 0).toDouble(),
      longitude: (json['lng'] ?? json['lon'] ?? json['longitude'] ?? 0).toDouble(),
      formattedAddress: json['display_name'] ?? json['formatted_address'] ?? json['address'] ?? '',
      street: json['street'] ?? json['road'] ?? '',
      area: json['area'] ?? json['suburb'] ?? json['quarter'] ?? '',
      city: json['city'] ?? json['town'] ?? json['village'] ?? json['municipality'] ?? '',
      region: json['region'] ?? json['state'] ?? '',
      country: json['country'] ?? 'Cameroon',
      postalCode: json['postcode'] ?? '',
    );
  }
}
