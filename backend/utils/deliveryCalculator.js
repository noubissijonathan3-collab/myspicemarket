const EARTH_RADIUS_KM = 6371;
const DEFAULT_STORE_LAT = 4.0511;
const DEFAULT_STORE_LNG = 9.7679;

function toRadians(degrees) {
  return degrees * (Math.PI / 180);
}

function haversine(lat1, lng1, lat2, lng2) {
  const dLat = toRadians(lat2 - lat1);
  const dLng = toRadians(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) * Math.sin(dLng / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return EARTH_RADIUS_KM * c;
}

function distanceFromStore(lat, lng) {
  return haversine(lat, lng, DEFAULT_STORE_LAT, DEFAULT_STORE_LNG);
}

function estimateMinutes(km) {
  const avgSpeedKmph = 25;
  return Math.round((km / avgSpeedKmph) * 60 + 10);
}

function estimateDeliveryFee(km) {
  if (km <= 2) return 500;
  if (km <= 5) return 1000;
  if (km <= 10) return 1500;
  if (km <= 15) return 2000;
  if (km <= 20) return 3000;
  return 5000;
}

function getDeliveryStatus(distance, coverageRadius) {
  const maxRadius = coverageRadius || 25;
  if (distance > maxRadius) {
    return { available: false, message: 'Currently Unavailable' };
  }
  if (distance > maxRadius * 0.75) {
    return { available: true, message: 'Limited Coverage' };
  }
  if (distance > maxRadius * 0.4) {
    return { available: true, message: 'Busy' };
  }
  return { available: true, message: 'Available Now' };
}

function getFullEstimate(lat, lng, coverageRadius) {
  const dist = distanceFromStore(lat, lng);
  const minutes = estimateMinutes(dist);
  const fee = estimateDeliveryFee(dist);
  const status = getDeliveryStatus(dist, coverageRadius);
  return {
    distance: `${dist.toFixed(1)} km`,
    duration: `${minutes}–${minutes + 10} minutes`,
    deliveryFee: fee,
    available: status.available,
    message: status.message,
    coverageRadius: coverageRadius || 25,
  };
}

module.exports = {
  haversine,
  distanceFromStore,
  estimateMinutes,
  estimateDeliveryFee,
  getDeliveryStatus,
  getFullEstimate,
};
