import 'dart:math';

class DistanceCalculator {
  DistanceCalculator._();

  static const double earthRadiusKm = 6371;
  static const double defaultStoreLat = 4.0511;
  static const double defaultStoreLng = 9.7679;

  static double haversine(double lat1, double lng1, double lat2, double lng2) {
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double distanceFromStore(double lat, double lng) {
    return haversine(lat, lng, defaultStoreLat, defaultStoreLng);
  }

  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  static int estimateMinutes(double km) {
    const avgSpeedKmph = 25;
    return (km / avgSpeedKmph * 60 + 10).round();
  }

  static double estimateDeliveryFee(double km) {
    if (km <= 2) return 500;
    if (km <= 5) return 1000;
    if (km <= 10) return 1500;
    if (km <= 15) return 2000;
    if (km <= 20) return 3000;
    return 5000;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
