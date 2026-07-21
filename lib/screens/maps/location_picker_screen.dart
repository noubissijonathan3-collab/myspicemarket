import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../providers/location_provider.dart';
import '../../services/location_service.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();

  late double _lat;
  late double _lng;
  String _currentAddress = '';
  bool _isLoadingAddress = false;
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat ?? 4.0511;
    _lng = widget.initialLng ?? 9.7679;
    _reverseGeocode();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _reverseGeocode() async {
    setState(() => _isLoadingAddress = true);
    try {
      final result = await LocationService.reverseGeocode(_lat, _lng);
      setState(() {
        _currentAddress = result['display_name'] ?? result['formatted_address'] ?? 'Unknown location';
        _isLoadingAddress = false;
      });
    } catch (_) {
      setState(() {
        _currentAddress = '$_lat, $_lng';
        _isLoadingAddress = false;
      });
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _lat = position.latitude;
      _lng = position.longitude;
    });
    _reverseGeocode();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value));
  }

  Future<void> _search(String query) async {
    try {
      final results = await LocationService.searchLocation(query);
      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (_) { }
  }

  Future<void> _goToResult(Map<String, dynamic> result) async {
    final lat = double.tryParse((result['lat'] ?? result['geometry']?['location']?['lat'] ?? '').toString());
    final lng = double.tryParse((result['lon'] ?? result['geometry']?['location']?['lng'] ?? '').toString());
    if (lat == null || lng == null) return;

    setState(() {
      _lat = lat;
      _lng = lng;
      _currentAddress = result['display_name'] ?? result['formatted_address'] ?? result['description'] ?? '';
      _searchResults = [];
      _searchCtrl.clear();
    });

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));
  }

  void _confirmLocation() {
    final provider = context.read<LocationProvider>();
    final address = AddressModel(
      id: 'gps_${DateTime.now().millisecondsSinceEpoch}',
      label: 'Selected Location',
      street: _currentAddress,
      latitude: _lat,
      longitude: _lng,
    );
    provider.setAddress(address);
    Helpers.showSnackBar(context, 'Delivery location updated');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Select Delivery Location', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildMap()),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      color: AppColors.surface,
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search for an area or address...',
              hintStyle: const TextStyle(color: AppColors.outlineVariant, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _searchResults = []); })
                  : null,
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          if (_searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                  title: Text(_searchResults[i]['display_name'] ?? _searchResults[i]['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                  onTap: () => _goToResult(_searchResults[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(_lat, _lng), zoom: 15),
          onMapCreated: _mapController.complete,
          onTap: _onMapTapped,
          onCameraMove: (position) {
            _lat = position.target.latitude;
            _lng = position.target.longitude;
          },
          onCameraIdle: _reverseGeocode,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
          compassEnabled: true,
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: AppColors.error, size: 40),
              Container(
                margin: const EdgeInsets.only(top: 36),
                child: Container(
                  width: 4, height: 4,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoadingAddress)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else ...[
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _currentAddress,
                      style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('$_lat, $_lng', style: const TextStyle(fontSize: 11, color: AppColors.outline)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _confirmLocation,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
