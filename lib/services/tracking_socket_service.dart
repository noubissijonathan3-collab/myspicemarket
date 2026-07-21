import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AgentLocationData {
  final String agentId;
  final String agentName;
  final String vehicleType;
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final String orderId;
  final String status;
  final double remainingDistance;
  final int estimatedArrival;
  final DateTime timestamp;

  AgentLocationData({
    required this.agentId,
    required this.agentName,
    this.vehicleType = '',
    required this.latitude,
    required this.longitude,
    this.speed = 0,
    this.heading = 0,
    this.orderId = '',
    this.status = 'en_route_to_customer',
    this.remainingDistance = 0,
    this.estimatedArrival = 0,
    required this.timestamp,
  });

  factory AgentLocationData.fromJson(Map<String, dynamic> json) {
    return AgentLocationData(
      agentId: json['agentId'] ?? '',
      agentName: json['agentName'] ?? 'Agent',
      vehicleType: json['vehicleType'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      speed: (json['speed'] ?? 0).toDouble(),
      heading: (json['heading'] ?? 0).toDouble(),
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? 'en_route_to_customer',
      remainingDistance: (json['remainingDistance'] ?? 0).toDouble(),
      estimatedArrival: (json['estimatedArrival'] ?? 0).toInt(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'en_route_to_pickup':
        return 'Heading to store';
      case 'arrived_at_pickup':
        return 'At store';
      case 'picked_up':
        return 'Package picked up';
      case 'en_route_to_customer':
        return 'On the way';
      case 'near_customer':
        return 'Arriving soon';
      case 'arrived':
        return 'Arrived';
      case 'delivered':
        return 'Delivered';
      default:
        return 'On the way';
    }
  }

  String get etaText {
    if (estimatedArrival <= 0) return '';
    final minutes = (estimatedArrival / 60000).ceil();
    return '$minutes min';
  }

  String get distanceText {
    if (remainingDistance <= 0) return '';
    if (remainingDistance < 1000) {
      return '${remainingDistance.round()} m';
    }
    return '${(remainingDistance / 1000).toStringAsFixed(1)} km';
  }
}

class TrackingSocketService {
  static io.Socket? _socket;
  static String? _currentToken;
  static String? _currentOrderId;
  static bool _isConnecting = false;

  static final StreamController<AgentLocationData> _locationController =
      StreamController<AgentLocationData>.broadcast();
  static Stream<AgentLocationData> get locationStream => _locationController.stream;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> connectAndTrack(String orderId) async {
    _currentOrderId = orderId;
    if (_socket != null && _socket!.connected) {
      _socket!.emit('tracking:join', {'orderId': orderId});
      return;
    }
    if (_isConnecting) return;
    _isConnecting = true;

    _currentToken = await _getToken();
    if (_currentToken == null) {
      _isConnecting = false;
      return;
    }

    _socket = io.io(AppConfig.baseUrl, io.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': _currentToken})
      .disableAutoConnect()
      .build());

    _socket!.on('connect', (_) {
      _isConnecting = false;
      debugPrint('Tracking socket connected');
      if (_currentOrderId != null) {
        _socket!.emit('tracking:join', {'orderId': _currentOrderId});
      }
    });

    _socket!.on('connect_error', (err) {
      _isConnecting = false;
      debugPrint('Tracking socket error: $err');
    });

    _socket!.on('agent:location', (data) {
      if (data is Map<String, dynamic>) {
        final location = AgentLocationData.fromJson(data);
        _locationController.add(location);
      }
    });

    _socket!.on('location:updated', (data) {
      if (data is Map<String, dynamic>) {
        final location = AgentLocationData.fromJson(data);
        if (_currentOrderId != null && location.orderId == _currentOrderId) {
          _locationController.add(location);
        }
      }
    });

    _socket!.connect();
  }

  static void disconnect() {
    if (_currentOrderId != null) {
      _socket?.emit('tracking:leave', {'orderId': _currentOrderId});
    }
    _currentOrderId = null;
  }

  static void dispose() {
    disconnect();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnecting = false;
  }
}
