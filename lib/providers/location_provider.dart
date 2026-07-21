import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../models/location_model.dart';
import '../services/address_service.dart';
import '../services/location_service.dart';
import '../utils/distance_calculator.dart';
import '../utils/location_permission.dart';

enum LocationStatus { unknown, loading, permissionDenied, gpsDisabled, available, unavailable }

class LocationProvider with ChangeNotifier {
  AddressModel? _currentAddress;
  LocationModel? _rawLocation;
  String _deliveryEstimate = '';
  double _deliveryFee = 0;
  double _distance = 0;
  bool _isAvailable = true;
  String _statusMessage = '';
  bool _isLoading = false;
  bool _locationEnabled = false;
  LocationStatus _status = LocationStatus.unknown;
  bool _permissionRequested = false;

  AddressModel? get currentAddress => _currentAddress;
  LocationModel? get rawLocation => _rawLocation;
  String get deliveryEstimate => _deliveryEstimate;
  double get deliveryFee => _deliveryFee;
  double get distance => _distance;
  bool get isAvailable => _isAvailable;
  String get statusMessage => _statusMessage;
  bool get isLoading => _isLoading;
  bool get locationEnabled => _locationEnabled;
  LocationStatus get status => _status;
  bool get permissionRequested => _permissionRequested;

  Future<void> detectLocation() async {
    _isLoading = true;
    _status = LocationStatus.loading;
    _permissionRequested = true;
    notifyListeners();

    final hasPermission = await LocationPermissionUtil.hasPermission();
    if (!hasPermission) {
      final granted = await LocationPermissionUtil.requestPermission();
      if (!granted) {
        _isLoading = false;
        _locationEnabled = false;
        _status = LocationStatus.permissionDenied;
        _statusMessage = 'Location permission denied';
        notifyListeners();
        return;
      }
    }

    final serviceEnabled = await LocationPermissionUtil.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isLoading = false;
      _locationEnabled = false;
      _status = LocationStatus.gpsDisabled;
      _statusMessage = 'GPS is disabled';
      notifyListeners();
      return;
    }

    final position = await LocationPermissionUtil.getCurrentPosition();
    if (position == null) {
      _isLoading = false;
      _locationEnabled = false;
      _status = LocationStatus.gpsDisabled;
      _statusMessage = 'Could not get GPS position';
      notifyListeners();
      return;
    }

    await updateFromGps(position.latitude, position.longitude);
  }

  Future<void> updateFromGps(double lat, double lng) async {
    _isLoading = true;
    _locationEnabled = true;
    _status = LocationStatus.loading;
    notifyListeners();

    _rawLocation = LocationModel(latitude: lat, longitude: lng);

    try {
      final result = await LocationService.reverseGeocode(lat, lng);
      final loc = LocationModel.fromJson(result);
      _rawLocation = loc;

      _currentAddress = AddressModel(
        id: 'gps',
        label: 'Current Location',
        latitude: lat,
        longitude: lng,
        street: loc.street,
        area: loc.area,
        city: loc.city,
        state: loc.region,
        country: loc.country.isNotEmpty ? loc.country : 'Cameroon',
      );

      _distance = DistanceCalculator.distanceFromStore(lat, lng);
      _deliveryFee = DistanceCalculator.estimateDeliveryFee(_distance);
      final minutes = DistanceCalculator.estimateMinutes(_distance);
      _deliveryEstimate = '$minutes–${minutes + 10} minutes';

      final estimate = await LocationService.getDeliveryEstimate(lat, lng);
      if (estimate['available'] == false) {
        _isAvailable = false;
        _status = LocationStatus.unavailable;
        _statusMessage = estimate['message'] ?? 'Currently unavailable in your area';
      } else {
        _isAvailable = true;
        _status = LocationStatus.available;
        _statusMessage = estimate['message'] ?? 'Available Now';
        if (estimate['duration'] != null) _deliveryEstimate = estimate['duration'];
      }
    } catch (_) {
      _isAvailable = false;
      _locationEnabled = true;
      _status = LocationStatus.unavailable;
      _statusMessage = 'Could not determine delivery area';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setAddress(AddressModel address) {
    _currentAddress = address;
    _rawLocation = LocationModel(
      latitude: address.latitude ?? 0,
      longitude: address.longitude ?? 0,
      formattedAddress: address.fullAddress,
    );
    _locationEnabled = true;
    _status = LocationStatus.available;
    _statusMessage = 'Available Now';
    if (address.latitude != null && address.longitude != null) {
      _distance = DistanceCalculator.distanceFromStore(address.latitude!, address.longitude!);
      _deliveryFee = DistanceCalculator.estimateDeliveryFee(_distance);
      final minutes = DistanceCalculator.estimateMinutes(_distance);
      _deliveryEstimate = '$minutes–${minutes + 10} minutes';
    }
    notifyListeners();
  }

  void setLocationDisabled() {
    _locationEnabled = false;
    _status = LocationStatus.gpsDisabled;
    _statusMessage = 'Enable location services';
    notifyListeners();
  }

  void setPermissionDenied() {
    _locationEnabled = false;
    _status = LocationStatus.permissionDenied;
    _statusMessage = 'Location permission denied';
    notifyListeners();
  }

  Future<void> loadDefaultAddress() async {
    try {
      final address = await AddressService.fetchDefaultAddress();
      if (address != null) {
        _currentAddress = address;
        _locationEnabled = true;
        _status = LocationStatus.available;
        _statusMessage = 'Available Now';
        notifyListeners();
      }
    } catch (_) {}
  }

  void reset() {
    _currentAddress = null;
    _rawLocation = null;
    _deliveryEstimate = '';
    _deliveryFee = 0;
    _distance = 0;
    _isAvailable = true;
    _statusMessage = '';
    _locationEnabled = false;
    _status = LocationStatus.unknown;
    _permissionRequested = false;
    notifyListeners();
  }
}
