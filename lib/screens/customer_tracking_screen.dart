import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../services/chat_service.dart';
import 'call_screen.dart';
import 'chat/chat_screen.dart';

class CustomerTrackingScreen extends StatefulWidget {
  final String orderId;
  final String agentId;
  final String agentName;
  final String agentPhone;
  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;

  const CustomerTrackingScreen({
    super.key,
    required this.orderId,
    required this.agentId,
    required this.agentName,
    this.agentPhone = '',
    this.destinationAddress = '',
    required this.destinationLat,
    required this.destinationLng,
  });

  @override
  State<CustomerTrackingScreen> createState() => _CustomerTrackingScreenState();
}

class _CustomerTrackingScreenState extends State<CustomerTrackingScreen> {
  IO.Socket? _socket;
  final MapController _mapController = MapController();

  LatLng _agentPos = const LatLng(4.0511, 9.7679);
  LatLng _destination = const LatLng(4.0511, 9.7679);
  double _distance = 0;
  int _etaMinutes = 0;
  String _agentStatus = 'On The Way';
  bool _isConnected = false;
  String _vehicleType = '';

  @override
  void initState() {
    super.initState();
    _destination = LatLng(widget.destinationLat, widget.destinationLng);
    _connectSocket();
  }

  void _connectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    _socket = IO.io(
      AppConfig.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .setAuth({'token': token ?? ''})
          .build(),
    );

    _socket!.onConnect((_) {
      setState(() => _isConnected = true);
      _socket!.emit('tracking:join', {'orderId': widget.orderId});
    });

    _socket!.onDisconnect((_) => setState(() => _isConnected = false));

    _socket!.on('agent:location', (data) {
      if (data is Map && mounted) {
        setState(() {
          _agentPos = LatLng(
            (data['latitude'] ?? _agentPos.latitude).toDouble(),
            (data['longitude'] ?? _agentPos.longitude).toDouble(),
          );
          _vehicleType = data['vehicleType'] ?? _vehicleType;
        });
        _calculateDistance();
        _mapController.move(_agentPos, _mapController.camera.zoom);
      }
    });

    _socket!.on('location:updated', (data) {
      if (data is Map && data['orderId'] == widget.orderId && mounted) {
        setState(() {
          _agentPos = LatLng(
            (data['latitude'] ?? _agentPos.latitude).toDouble(),
            (data['longitude'] ?? _agentPos.longitude).toDouble(),
          );
        });
        _calculateDistance();
      }
    });
  }

  void _calculateDistance() {
    final dist = geo.Geolocator.distanceBetween(
      _agentPos.latitude, _agentPos.longitude,
      _destination.latitude, _destination.longitude,
    );
    final eta = (dist / 12.5 / 60).round();
    if (mounted) {
      setState(() {
        _distance = dist;
        _etaMinutes = eta > 0 ? eta : 1;
      });
    }
  }

  void _openChat() async {
    String? chatRoomId;
    try {
      final room = await ChatService.getChatRoom(widget.orderId);
      if (room != null) {
        chatRoomId = room['id'] ?? room['_id'];
      }
    } catch (_) {}

    if (chatRoomId == null) {
      try {
        final room = await ChatService.createChatRoom(widget.orderId);
        chatRoomId = room['id'] ?? room['_id'];
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatRoomId: chatRoomId ?? widget.orderId,
          orderId: widget.orderId,
          agentName: widget.agentName,
          agentAvatar: '',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socket?.emit('tracking:leave', {'orderId': widget.orderId});
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(
        point: _agentPos,
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 12)],
          ),
          child: const Icon(Icons.delivery_dining, color: Colors.white, size: 22),
        ),
      ),
      Marker(
        point: _destination,
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF198754),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Icon(Icons.home, color: Colors.white, size: 22),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Track Order', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _isConnected ? const Color(0xFF198754) : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(_isConnected ? 'LIVE' : '...', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: _agentPos, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.myspicemarket.customer',
                ),
                MarkerLayer(markers: markers),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_agentPos, _destination],
                      color: Colors.blue.withValues(alpha: 0.5),
                      strokeWidth: 3,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildInfoPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF198754), Color(0xFF2E7D32)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('$_etaMinutes min', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                const Text('Estimated Arrival', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat(Icons.straighten, '${(_distance / 1000).toStringAsFixed(1)} km', 'Distance'),
              _stat(Icons.person, widget.agentName, 'Driver'),
              _stat(Icons.circle, _agentStatus, 'Status', color: Colors.blue),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                          targetUserId: widget.agentId,
                          targetName: widget.agentName,
                          orderId: widget.orderId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call Driver'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF198754),
                    side: const BorderSide(color: Color(0xFF198754)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openChat,
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, {Color? color}) {
    final c = color ?? Colors.black87;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: TextStyle(color: c.withValues(alpha: 0.6), fontSize: 10)),
        ],
      ),
    );
  }
}
