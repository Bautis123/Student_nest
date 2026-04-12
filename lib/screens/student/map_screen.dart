import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/map_style.dart';

class MapScreen extends StatefulWidget {
  final String? focusedPropertyId;

  const MapScreen({super.key, this.focusedPropertyId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _api = ApiService();
  GoogleMapController? _mapController;

  BitmapDescriptor _boardingHouseMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueAzure,
  );
  BitmapDescriptor _schoolMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueYellow,
  );
  bool _didAttemptMarkerIconLoad = false;

  List<Property> _properties = const [];
  List<Map<String, dynamic>> _schools = const [];
  Set<Marker> _markers = const {};
  bool _isLoading = true;

  static const LatLng _fallbackCenter = LatLng(
    AppConstants.defaultLat,
    AppConstants.defaultLng,
  );
  static const LatLng _unzaLocation = LatLng(
    AppConstants.defaultLat,
    AppConstants.defaultLng,
  );

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAttemptMarkerIconLoad) return;
    _didAttemptMarkerIconLoad = true;
    _loadCustomMarkerIcons();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    try {
      final results = await Future.wait<dynamic>([
        _api.getProperties(),
        _api.getSchools(),
      ]);

      final properties = results[0] as List<Property>;
      final schools = results[1] as List<Map<String, dynamic>>;

      if (!mounted) return;

      setState(() {
        _properties = properties;
        _schools = schools;
        _markers = _buildMarkers(properties: properties, schools: schools);
        _isLoading = false;
      });

      _focusInitialTarget();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _properties = const [];
        _schools = const [];
        _markers = const {};
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomMarkerIcons() async {
    BitmapDescriptor boardingHouseIcon = _boardingHouseMarkerIcon;
    BitmapDescriptor schoolIcon = _schoolMarkerIcon;

    try {
      boardingHouseIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(42, 42)),
        'assets/map_markers/boarding_house.png',
      );
    } catch (_) {}

    try {
      schoolIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(42, 42)),
        'assets/map_markers/school.png',
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _boardingHouseMarkerIcon = boardingHouseIcon;
      _schoolMarkerIcon = schoolIcon;
      _markers = _buildMarkers(properties: _properties, schools: _schools);
    });
  }

  Set<Marker> _buildMarkers({
    required List<Property> properties,
    required List<Map<String, dynamic>> schools,
  }) {
    final markers = <Marker>{};
    var hasUnzaMarker = false;

    for (final school in schools) {
      final name = school['name']?.toString() ?? 'School';
      final isUnza = _looksLikeUnza(name);
      final lat =
          isUnza
              ? AppConstants.defaultLat
              : _toDouble(school['latitude'] ?? school['lat']);
      final lng =
          isUnza
              ? AppConstants.defaultLng
              : _toDouble(school['longitude'] ?? school['lng']);
      if (lat == null || lng == null) continue;

      final id = school['id']?.toString() ?? school['name']?.toString() ?? 'school';
      if (isUnza) hasUnzaMarker = true;

      markers.add(
        Marker(
          markerId: MarkerId('school-$id'),
          position: LatLng(lat, lng),
          icon: _schoolMarkerIcon,
          infoWindow: InfoWindow(title: name),
        ),
      );
    }

    if (!hasUnzaMarker) {
      markers.add(
        Marker(
          markerId: const MarkerId('school-unza'),
          position: _unzaLocation,
          icon: _schoolMarkerIcon,
          infoWindow: const InfoWindow(title: 'University of Zambia'),
        ),
      );
    }

    for (final property in properties) {
      final minPrice = property.minPrice;
      markers.add(
        Marker(
          markerId: MarkerId('property-${property.id}'),
          position: LatLng(property.latitude, property.longitude),
          icon: _boardingHouseMarkerIcon,
          infoWindow: InfoWindow(
            title: property.title,
            snippet:
                minPrice != null
                    ? 'From K${minPrice.toStringAsFixed(0)}/mo'
                    : 'Boarding house',
          ),
        ),
      );
    }

    return markers;
  }

  bool _looksLikeUnza(String name) {
    final normalized = name.toLowerCase();
    return normalized.contains('unza') ||
        normalized.contains('university of zambia');
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  LatLng _initialCenter() {
    final unzaSchool = _schools.cast<Map<String, dynamic>?>().firstWhere(
      (school) => _looksLikeUnza(school?['name']?.toString() ?? ''),
      orElse: () => null,
    );
    if (unzaSchool != null) {
      return const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);
    }
    final firstSchool = unzaSchool ?? (_schools.isNotEmpty ? _schools.first : null);
    final schoolLat = _toDouble(firstSchool?['latitude'] ?? firstSchool?['lat']);
    final schoolLng = _toDouble(
      firstSchool?['longitude'] ?? firstSchool?['lng'],
    );

    if (schoolLat != null && schoolLng != null) {
      return LatLng(schoolLat, schoolLng);
    }

    return _fallbackCenter;
  }

  void _focusInitialTarget() {
    if (_mapController == null) return;

    if (widget.focusedPropertyId != null) {
      final match = _properties.where((p) => p.id == widget.focusedPropertyId);
      if (match.isNotEmpty) {
        final p = match.first;
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(p.latitude, p.longitude), zoom: 16),
          ),
        );
        return;
      }
    }

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _initialCenter(), zoom: AppConstants.defaultZoom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialCenter(),
              zoom: AppConstants.defaultZoom,
            ),
            style: AppMapStyle.boardingHouseMap,
            markers: _markers,
            mapType: MapType.normal,
            compassEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            buildingsEnabled: false,
            trafficEnabled: false,
            indoorViewEnabled: false,
            onMapCreated: (controller) async {
              _mapController = controller;
              _focusInitialTarget();
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.78),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
