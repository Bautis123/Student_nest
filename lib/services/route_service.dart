import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RoutePathResult {
  final List<LatLng> points;
  final double? distanceKm;
  final int? durationMin;
  final String status;
  final String? error;

  const RoutePathResult({
    required this.points,
    required this.distanceKm,
    required this.durationMin,
    required this.status,
    this.error,
  });
}

class RouteService {
  RouteService._();
  static final RouteService _instance = RouteService._();
  factory RouteService() => _instance;

  final Map<String, double?> _walkingDistanceCache = {};
  final Map<String, int?> _cyclingDurationCache = {};
  final Map<String, RoutePathResult?> _walkingRouteCache = {};

  final Map<String, Future<double?>> _walkingDistanceInFlight = {};
  final Map<String, Future<int?>> _cyclingDurationInFlight = {};
  final Map<String, Future<RoutePathResult?>> _walkingRouteInFlight = {};

  String _key(double aLat, double aLng, double bLat, double bLng) {
    String fixed(double value) => value.toStringAsFixed(5);
    return '${fixed(aLat)},${fixed(aLng)}->${fixed(bLat)},${fixed(bLng)}';
  }

  Future<double?> getWalkingDistanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final key = _key(fromLat, fromLng, toLat, toLng);
    if (_walkingDistanceCache.containsKey(key)) {
      return Future.value(_walkingDistanceCache[key]);
    }
    if (_walkingDistanceInFlight.containsKey(key)) {
      return _walkingDistanceInFlight[key]!;
    }

    final task = _fetchWalkingDistanceKm(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );
    _walkingDistanceInFlight[key] = task;
    task.whenComplete(() => _walkingDistanceInFlight.remove(key));
    return task;
  }

  Future<double?> _fetchWalkingDistanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final response = await _requestRoute(
      profile: 'walking',
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
      fullOverview: false,
    );
    if (response == null) return null;

    final distanceMeters = response['distance'] as num?;
    final value =
        distanceMeters != null ? distanceMeters.toDouble() / 1000 : null;
    _walkingDistanceCache[_key(fromLat, fromLng, toLat, toLng)] = value;
    return value;
  }

  Future<int?> getCyclingDurationMin({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final key = _key(fromLat, fromLng, toLat, toLng);
    if (_cyclingDurationCache.containsKey(key)) {
      return Future.value(_cyclingDurationCache[key]);
    }
    if (_cyclingDurationInFlight.containsKey(key)) {
      return _cyclingDurationInFlight[key]!;
    }

    final task = _fetchCyclingDurationMin(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );
    _cyclingDurationInFlight[key] = task;
    task.whenComplete(() => _cyclingDurationInFlight.remove(key));
    return task;
  }

  Future<int?> _fetchCyclingDurationMin({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final response = await _requestRoute(
      profile: 'cycling',
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
      fullOverview: false,
    );
    if (response == null) return null;

    final durationSeconds = response['duration'] as num?;
    final value =
        durationSeconds != null
            ? (durationSeconds.toDouble() / 60).ceil()
            : null;
    _cyclingDurationCache[_key(fromLat, fromLng, toLat, toLng)] = value;
    return value;
  }

  Future<RoutePathResult?> getWalkingRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final key = _key(fromLat, fromLng, toLat, toLng);
    if (_walkingRouteCache.containsKey(key)) {
      return Future.value(_walkingRouteCache[key]);
    }
    if (_walkingRouteInFlight.containsKey(key)) {
      return _walkingRouteInFlight[key]!;
    }

    final task = _fetchWalkingRoute(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );
    _walkingRouteInFlight[key] = task;
    task.whenComplete(() => _walkingRouteInFlight.remove(key));
    return task;
  }

  Future<RoutePathResult?> _fetchWalkingRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final response = await _requestRoute(
        profile: 'walking',
        fromLat: fromLat,
        fromLng: fromLng,
        toLat: toLat,
        toLng: toLng,
        fullOverview: true,
      );
      if (response == null) {
        final fallback = const RoutePathResult(
          points: [],
          distanceKm: null,
          durationMin: null,
          status: 'NO_ROUTE',
        );
        _walkingRouteCache[_key(fromLat, fromLng, toLat, toLng)] = fallback;
        return fallback;
      }

      final distanceMeters = response['distance'] as num?;
      final durationSeconds = response['duration'] as num?;
      final geometry = response['geometry'] as Map<String, dynamic>?;
      final coordinates =
          geometry?['coordinates'] as List<dynamic>? ?? const [];
      final points = _decodeGeoJsonCoordinates(coordinates);

      final result = RoutePathResult(
        points: points,
        distanceKm:
            distanceMeters != null ? distanceMeters.toDouble() / 1000 : null,
        durationMin:
            durationSeconds != null
                ? (durationSeconds.toDouble() / 60).ceil()
                : null,
        status: 'OK',
      );
      _walkingRouteCache[_key(fromLat, fromLng, toLat, toLng)] = result;
      return result;
    } catch (e) {
      final failure = RoutePathResult(
        points: const [],
        distanceKm: null,
        durationMin: null,
        status: 'EXCEPTION',
        error: e.toString(),
      );
      _walkingRouteCache[_key(fromLat, fromLng, toLat, toLng)] = failure;
      return failure;
    }
  }

  Future<Map<String, dynamic>?> _requestRoute({
    required String profile,
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    required bool fullOverview,
  }) async {
    final origin = '$fromLng,$fromLat';
    final destination = '$toLng,$toLat';
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/$profile/$origin;$destination'
      '?overview=${fullOverview ? 'full' : 'false'}'
      '&geometries=geojson',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if ((data['code']?.toString().toLowerCase() ?? '') != 'ok') return null;
    final routes = data['routes'] as List<dynamic>? ?? const [];
    if (routes.isEmpty) return null;
    return routes.first as Map<String, dynamic>;
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
}
