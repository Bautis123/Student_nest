import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../models/property.dart';
import '../../../services/api_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/map_style.dart';
import '../../../utils/theme.dart';

class PropertyRouteMapSheet extends StatefulWidget {
  final Property property;

  const PropertyRouteMapSheet({super.key, required this.property});

  @override
  State<PropertyRouteMapSheet> createState() => _PropertyRouteMapSheetState();
}

class _PropertyRouteMapSheetState extends State<PropertyRouteMapSheet> {
  final ApiService _api = ApiService();
  GoogleMapController? _mapController;
  BitmapDescriptor _boardingHouseMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueAzure,
  );
  BitmapDescriptor _schoolMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueYellow,
  );
  bool _didAttemptMarkerIconLoad = false;

  late final LatLng _boardingHousePoint;
  LatLng _schoolPoint = const LatLng(
    AppConstants.defaultLat,
    AppConstants.defaultLng,
  );
  String _schoolName = 'University of Zambia';
  List<LatLng> _routePoints = const [];
  double? _routeDistanceKm;
  int? _routeDurationMin;
  int? _cycleRouteDurationMin;
  String _routeStatus = 'NOT_REQUESTED';
  String? _routeError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _boardingHousePoint = LatLng(
      widget.property.latitude,
      widget.property.longitude,
    );
    _loadSchoolPoint();
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

  Future<void> _loadSchoolPoint() async {
    try {
      final resolvedLat = widget.property.resolvedSchoolLat;
      final resolvedLng = widget.property.resolvedSchoolLng;
      if (resolvedLat != null && resolvedLng != null) {
        _schoolPoint = LatLng(resolvedLat, resolvedLng);
        _schoolName = widget.property.schoolName ?? _schoolName;
      } else {
      final schools = await _api.getSchools();
      final matched = _findDestinationSchool(schools);
      if (matched != null) {
        _schoolPoint = LatLng(matched.$1, matched.$2);
        _schoolName = matched.$3;
      }
      }
    } catch (_) {
      _schoolName = widget.property.schoolName ?? _schoolName;
    } finally {
      await _loadWalkingRoute();
      await _loadCyclingEta();
      if (mounted) {
        setState(() => _isLoading = false);
        _fitRouteBounds();
      }
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
    });
  }

  Future<void> _loadWalkingRoute() async {
    final origin =
        '${_boardingHousePoint.longitude},${_boardingHousePoint.latitude}';
    final destination = '${_schoolPoint.longitude},${_schoolPoint.latitude}';
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/walking/$origin;$destination'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        _routeStatus = 'HTTP_${response.statusCode}';
        return;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _routeStatus = (data['code']?.toString() ?? 'UNKNOWN');
      _routeError = data['message']?.toString();

      if (_routeStatus.toLowerCase() != 'ok') return;

      final routes = data['routes'] as List<dynamic>? ?? const [];
      if (routes.isEmpty) {
        _routeStatus = 'NO_ROUTES';
        return;
      }

      final route = routes.first as Map<String, dynamic>;
      final distanceMeters = route['distance'] as num?;
      final durationSeconds = route['duration'] as num?;
      final geometry = route['geometry'] as Map<String, dynamic>?;
      final coordinates = geometry?['coordinates'] as List<dynamic>? ?? const [];
      final decodedPoints = _decodeGeoJsonCoordinates(coordinates);
      if (decodedPoints.isEmpty) {
        _routeStatus = 'NO_GEOMETRY';
        return;
      }

      if (!mounted) return;
      setState(() {
        _routePoints = decodedPoints;
        _routeDistanceKm =
            distanceMeters != null ? distanceMeters.toDouble() / 1000 : null;
        _routeDurationMin =
            durationSeconds != null ? (durationSeconds.toDouble() / 60).ceil() : null;
      });
    } catch (e) {
      _routeStatus = 'EXCEPTION';
      _routeError = e.toString();
    }
  }

  Future<void> _loadCyclingEta() async {
    final origin =
        '${_boardingHousePoint.longitude},${_boardingHousePoint.latitude}';
    final destination = '${_schoolPoint.longitude},${_schoolPoint.latitude}';
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/cycling/$origin;$destination'
      '?overview=false',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = (data['code']?.toString() ?? '').toLowerCase();
      if (status != 'ok') return;

      final routes = data['routes'] as List<dynamic>? ?? const [];
      if (routes.isEmpty) return;

      final route = routes.first as Map<String, dynamic>;
      final durationSeconds = route['duration'] as num?;
      if (durationSeconds == null) return;

      if (!mounted) return;
      setState(() {
        _cycleRouteDurationMin = (durationSeconds.toDouble() / 60).ceil();
      });
    } catch (_) {}
  }

  List<LatLng> _decodeGeoJsonCoordinates(List<dynamic> coordinates) {
    final points = <LatLng>[];

    for (final coordinate in coordinates) {
      if (coordinate is! List || coordinate.length < 2) continue;
      final lng = double.tryParse(coordinate[0].toString());
      final lat = double.tryParse(coordinate[1].toString());
      if (lat == null || lng == null) continue;
      points.add(LatLng(lat, lng));
    }

    return points;
  }

  (double, double, String)? _findDestinationSchool(
    List<Map<String, dynamic>> schools,
  ) {
    bool looksLikeUnza(String value) {
      final name = value.toLowerCase();
      return name.contains('unza') || name.contains('university of zambia');
    }

    Map<String, dynamic>? selected;

    if (widget.property.nearestSchoolId != null) {
      final byId = schools.where(
        (school) =>
            school['id']?.toString() == widget.property.nearestSchoolId,
      );
      if (byId.isNotEmpty) selected = byId.first;
    }

    selected ??= schools.cast<Map<String, dynamic>?>().firstWhere(
      (school) => looksLikeUnza(school?['name']?.toString() ?? ''),
      orElse: () => null,
    );

    if (selected == null) return null;

    final lat = double.tryParse(
      (selected['latitude'] ?? selected['lat']).toString(),
    );
    final lng = double.tryParse(
      (selected['longitude'] ?? selected['lng']).toString(),
    );

    if (lat == null || lng == null) return null;

    final name =
        selected['name']?.toString().trim().isNotEmpty == true
            ? selected['name'].toString()
            : _schoolName;

    if (looksLikeUnza(name)) {
      return (AppConstants.defaultLat, AppConstants.defaultLng, name);
    }

    return (lat, lng, name);
  }

  void _fitRouteBounds() {
    if (_mapController == null) return;

    final samePoint =
        (_boardingHousePoint.latitude - _schoolPoint.latitude).abs() < 0.0001 &&
        (_boardingHousePoint.longitude - _schoolPoint.longitude).abs() <
            0.0001;

    if (samePoint) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _boardingHousePoint, zoom: 15.5),
        ),
      );
      return;
    }

    final swLat = _boardingHousePoint.latitude <= _schoolPoint.latitude
        ? _boardingHousePoint.latitude
        : _schoolPoint.latitude;
    final swLng = _boardingHousePoint.longitude <= _schoolPoint.longitude
        ? _boardingHousePoint.longitude
        : _schoolPoint.longitude;
    final neLat = _boardingHousePoint.latitude > _schoolPoint.latitude
        ? _boardingHousePoint.latitude
        : _schoolPoint.latitude;
    final neLng = _boardingHousePoint.longitude > _schoolPoint.longitude
        ? _boardingHousePoint.longitude
        : _schoolPoint.longitude;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(swLat, swLng),
          northeast: LatLng(neLat, neLng),
        ),
        88,
      ),
    );
  }

  double get _distanceKm {
    if (_routeDistanceKm != null) return _routeDistanceKm!;
    final distanceMeters = Geolocator.distanceBetween(
      _boardingHousePoint.latitude,
      _boardingHousePoint.longitude,
      _schoolPoint.latitude,
      _schoolPoint.longitude,
    );
    return distanceMeters / 1000;
  }

  int get _walkMinutes {
    if (_routeDurationMin != null) return _routeDurationMin!;
    // Average walking speed: 4.8 km/h.
    const kmPerMinute = 4.8 / 60;
    return (_distanceKm / kmPerMinute).ceil();
  }

  int get _cycleMinutes {
    if (_cycleRouteDurationMin != null) {
      return _cycleRouteDurationMin!;
    }
    if (_routeDurationMin != null) {
      // Fallback estimate if cycling route is unavailable.
      final estimated = (_routeDurationMin! * 0.38).ceil();
      if (estimated < _walkMinutes) return estimated < 1 ? 1 : estimated;
      return _walkMinutes > 1 ? _walkMinutes - 1 : 1;
    }
    // Average city cycling speed: 14 km/h.
    const kmPerMinute = 14 / 60;
    return (_distanceKm / kmPerMinute).ceil();
  }

  int get _caloriesEstimate {
    // Approx walking calories around 55 kcal per km.
    return (_distanceKm * 55).round();
  }

  Set<Marker> _markers() {
    return {
      Marker(
        markerId: const MarkerId('boarding-house'),
        position: _boardingHousePoint,
        icon: _boardingHouseMarkerIcon,
        infoWindow: InfoWindow(title: widget.property.title),
      ),
      Marker(
        markerId: const MarkerId('destination-school'),
        position: _schoolPoint,
        icon: _schoolMarkerIcon,
        infoWindow: InfoWindow(title: _schoolName),
      ),
    };
  }

  Set<Polyline> _routeLine() {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: AppTheme.primary,
        width: 5,
        points:
            _routePoints.isNotEmpty
                ? _routePoints
                : [_boardingHousePoint, _schoolPoint],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.property.title;
    final distance = _distanceKm.toStringAsFixed(2);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.gray.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Walking Route',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.dark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _boardingHousePoint,
                        zoom: 14.5,
                      ),
                      style: AppMapStyle.boardingHouseMap,
                      markers: _markers(),
                      polylines: _routeLine(),
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _fitRouteBounds();
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_walk_rounded,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$title -> $_schoolName',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.dark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _DetailChip(
                          icon: Icons.straighten_rounded,
                          label: '$distance km',
                          helper: 'Walking distance',
                        ),
                        const SizedBox(width: 8),
                        _DetailChip(
                          icon: Icons.hiking_rounded,
                          label: '$_walkMinutes min',
                          helper: 'On foot',
                        ),
                        const SizedBox(width: 8),
                        _DetailChip(
                          icon: Icons.directions_bike_rounded,
                          label: '$_cycleMinutes min',
                          helper: 'By bike',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _DetailChip(
                          icon: Icons.local_fire_department_outlined,
                          label: '~$_caloriesEstimate kcal',
                          helper: 'Walk burn',
                        ),
                        const SizedBox(width: 8),
                        _DetailChip(
                          icon: Icons.info_outline,
                          label: _isLoading ? 'Syncing school' : 'Route ready',
                          helper:
                              _isLoading
                                  ? 'Please wait'
                                  : (_routePoints.isNotEmpty
                                      ? 'Walking route'
                                      : '$_routeStatus${_routeError != null ? ' (${_routeError!})' : ''}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String helper;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppTheme.primary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.dark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              helper,
              style: const TextStyle(fontSize: 11, color: AppTheme.gray),
            ),
          ],
        ),
      ),
    );
  }
}
