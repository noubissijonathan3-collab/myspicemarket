import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/tracking_service.dart';
import '../../services/tracking_socket_service.dart';
import '../../utils/colors.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String orderId;

  const LiveTrackingScreen({super.key, required this.orderId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final MapController _mapController = MapController();
  Map<String, dynamic>? _order;
  AgentLocationData? _agentLocation;
  List<LatLng> _routePoints = [];
  bool _loading = true;
  StreamSubscription<AgentLocationData>? _locationSub;

  static const LatLng _storeLocation = LatLng(4.0511, 9.7679);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadOrder();
    _startTracking();
  }

  Future<void> _loadOrder() async {
    try {
      final data = await OrderService.fetchOrderById(widget.orderId);
      final order = data['order'] as Map<String, dynamic>? ?? data;
      if (mounted) {
        setState(() {
          _order = order;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startTracking() {
    TrackingSocketService.connectAndTrack(widget.orderId);
    _locationSub = TrackingSocketService.locationStream.listen((location) {
      if (mounted) {
        setState(() => _agentLocation = location);
        _fitBounds();
      }
    });
    _fetchInitialLocation();
  }

  Future<void> _fetchInitialLocation() async {
    if (_order == null) return;
    final agentId = _order!['deliveryAgent'];
    if (agentId == null) return;

    final agentIdStr = agentId is String ? agentId : (agentId is Map ? agentId['_id'] ?? '' : '');
    if (agentIdStr.isEmpty) return;

    final location = await TrackingService.getAgentLocation(agentIdStr);
    if (location != null && mounted) {
      final agentData = AgentLocationData.fromJson(location);
      setState(() => _agentLocation = agentData);
      _fitBounds();
      _loadRoute(agentData.latitude, agentData.longitude);
    }
  }

  Future<void> _loadRoute(double agentLat, double agentLng) async {
    final dest = _getDeliveryLocation();
    if (dest == null) return;

    final coords = await TrackingService.getRoute(
      startLat: agentLat,
      startLng: agentLng,
      endLat: dest.latitude,
      endLng: dest.longitude,
    );

    if (mounted && coords.isNotEmpty) {
      setState(() {
        _routePoints = coords.map((c) {
          final list = c as List;
          return LatLng(list[1].toDouble(), list[0].toDouble());
        }).toList();
      });
    }
  }

  LatLng? _getDeliveryLocation() {
    if (_order == null) return null;
    final delivery = _order!['delivery'];
    if (delivery is Map) {
      final lat = delivery['latitude'];
      final lng = delivery['longitude'];
      if (lat != null && lng != null) {
        return LatLng(lat.toDouble(), lng.toDouble());
      }
    }
    return null;
  }

  void _fitBounds() {
    if (_agentLocation == null) return;
    final agentPos = LatLng(_agentLocation!.latitude, _agentLocation!.longitude);
    final dest = _getDeliveryLocation();
    if (dest != null) {
      final bounds = LatLngBounds.fromPoints([agentPos, dest]);
      _mapController.fitCamera(CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60),
      ));
    } else {
      _mapController.move(agentPos, 15);
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    TrackingSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Tracking', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(flex: 3, child: _buildMap()),
                Expanded(flex: 2, child: _buildInfoPanel()),
              ],
            ),
    );
  }

  Widget _buildMap() {
    final agentPos = _agentLocation != null
        ? LatLng(_agentLocation!.latitude, _agentLocation!.longitude)
        : _storeLocation;
    final dest = _getDeliveryLocation();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: agentPos,
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.myspicemarket.app',
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: AppColors.primary,
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(markers: [
          Marker(
            point: _storeLocation,
            width: 36,
            height: 36,
            child: Container(
              decoration: const BoxDecoration(color: AppColors.tertiary, shape: BoxShape.circle),
              child: const Icon(Icons.store, color: Colors.white, size: 18),
            ),
          ),
          if (dest != null)
            Marker(
              point: dest,
              width: 36,
              height: 36,
              child: Container(
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.home, color: Colors.white, size: 18),
              ),
            ),
          if (_agentLocation != null)
            Marker(
              point: agentPos,
              width: 44,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
                ),
                child: const Icon(Icons.delivery_dining, color: AppColors.primary, size: 22),
              ),
            ),
        ]),
      ],
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            if (_agentLocation != null) ...[
              _buildAgentCard(),
              const SizedBox(height: 12),
              _buildStatusTimeline(),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.explore, size: 48, color: AppColors.outline.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text('Waiting for delivery agent location...',
                        style: TextStyle(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
            if (_order != null) ...[
              const SizedBox(height: 12),
              _buildOrderInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAgentCard() {
    final loc = _agentLocation!;
    final agentName = loc.agentName.isNotEmpty ? loc.agentName : 'Delivery Agent';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
            child: const Icon(Icons.delivery_dining, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agentName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(loc.statusLabel, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (loc.etaText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: Text(loc.etaText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              if (loc.distanceText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(loc.distanceText, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    const steps = [
      'Picked up',
      'On the way',
      'Near you',
      'Arrived',
    ];
    const keys = ['picked_up', 'en_route_to_customer', 'near_customer', 'arrived'];
    final current = _agentLocation!.status;
    final currentIdx = keys.indexOf(current);

    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = currentIdx >= i;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.outlineVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isActive && currentIdx > i ? AppColors.primary : AppColors.outlineVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(steps[i], style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              )),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderInfo() {
    final order = _order!;
    final delivery = order['delivery'];
    final address = delivery is Map ? (delivery['address'] ?? '') : '';
    final total = order['total'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('Order #${widget.orderId.substring(widget.orderId.length - 6)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              Text('XAF ${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(address, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
