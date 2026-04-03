import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'property_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _api = ApiService();
  GoogleMapController? _mapController;
  List<Property> _properties = [];
  Set<Marker> _markers = {};
  Property? _selectedProperty;
  bool _isLoading = true;

  static const LatLng _unzaLocation = LatLng(
    AppConstants.defaultLat,
    AppConstants.defaultLng,
  );

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      final properties = await _api.getProperties();
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
      _buildMarkers();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _buildMarkers() {
    final markers = <Marker>{};

    // UNZA marker
    markers.add(
      Marker(
        markerId: const MarkerId('unza'),
        position: _unzaLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'University of Zambia'),
      ),
    );

    // Property markers
    for (final property in _properties) {
      final minPrice = property.minPrice;
      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: LatLng(property.latitude, property.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: property.title,
            snippet:
                minPrice != null
                    ? 'From K${minPrice.toStringAsFixed(0)}/mo'
                    : null,
          ),
          onTap: () => setState(() => _selectedProperty = property),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _unzaLocation,
              zoom: AppConstants.defaultZoom,
            ),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            onTap: (_) => setState(() => _selectedProperty = null),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Loading
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 8,
                16,
                12,
              ),
              decoration: const BoxDecoration(color: AppTheme.primary),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Map View',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Boarding houses near UNZA',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_properties.length} listings',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected property card
          if (_selectedProperty != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PropertyDetailScreen(
                              propertyId: _selectedProperty!.id,
                            ),
                      ),
                    ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.home_work_outlined,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedProperty!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppTheme.dark,
                              ),
                            ),
                            if (_selectedProperty!.distanceFromSchool != null)
                              Text(
                                '${_selectedProperty!.distanceFromSchool!.toStringAsFixed(2)} km from UNZA',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primary,
                                ),
                              ),
                            if (_selectedProperty!.minPrice != null)
                              Text(
                                'From K${_selectedProperty!.minPrice!.toStringAsFixed(0)}/mo',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.gray,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.gray),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
