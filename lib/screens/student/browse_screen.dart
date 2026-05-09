import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../services/route_service.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/utils/formatters.dart';
import 'browse/browse_filters.dart';
import 'browse/browse_filters_sheet.dart';
import 'browse/browse_results_sliver.dart';
import 'browse/browse_school_summary.dart';
import 'browse/browse_search_app_bar.dart';
import 'browse/school_picker_sheet.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({
    super.key,
    this.savedPropertyIds = const {},
    this.onSavedToggle,
    this.onPropertiesLoaded,
  });

  final Set<String> savedPropertyIds;
  final void Function(Property property, bool isSaved)? onSavedToggle;
  final ValueChanged<List<Property>>? onPropertiesLoaded;

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  static const String _allSchoolsValue = '__all_schools__';
  static const String _preferredSchoolIdKey = 'preferred_school_id';

  final ApiService _api = ApiService();
  final RouteService _routeService = RouteService();
  final ScrollController _scrollController = ScrollController();
  List<Property> _properties = [];
  List<Map<String, dynamic>> _schools = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedSchoolId;
  Timer? _searchDebounce;
  Set<BrowseFilter> _selectedFilters = {BrowseFilter.suggested};
  final Map<String, double> _walkingDistanceByPropertyId = {};
  final Map<String, int> _walkingMinutesByPropertyId = {};
  final Map<String, String> _walkingSchoolByPropertyId = {};
  bool _loadingWalkingDistances = false;
  int _distanceLoadCursor = 0;
  int _routeLoadVersion = 0;
  static const int _distanceBatchSize = 8;
  String _locationLabel = 'Locating...';

  int _propertiesVersion = 0;
  int _cachedVersion = -1;
  String _cachedQuery = '';
  String? _cachedSchoolId;
  String _cachedFiltersKey = '';
  List<Property> _cachedFilteredProperties = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    unawaited(_loadPreferredSchool());
    unawaited(_loadCurrentLocationLabel());
    unawaited(_loadSchools());
    _loadProperties();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final properties = await _api.getProperties();
      setState(() {
        _properties = properties;
        _walkingDistanceByPropertyId.clear();
        _walkingMinutesByPropertyId.clear();
        _walkingSchoolByPropertyId.clear();
        _distanceLoadCursor = 0;
        _propertiesVersion++;
        _isLoading = false;
      });
      widget.onPropertiesLoaded?.call(properties);
      if (_selectedSchoolLocation != null) {
        unawaited(_loadNextDistanceBatch(properties));
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load listings. Check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPreferredSchool() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolId = prefs.getString(_preferredSchoolIdKey);
    if (!mounted || schoolId == null || schoolId.isEmpty) return;
    setState(() {
      _selectedSchoolId = schoolId;
      _resetWalkingRoutes();
    });
    if (_properties.isNotEmpty) {
      unawaited(_loadWalkingDistances(_properties));
    }
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await _api.getSchools();
      if (!mounted) return;
      setState(() {
        _schools = schools;
        _resetWalkingRoutes();
      });
      if (_properties.isNotEmpty && _selectedSchoolLocation != null) {
        unawaited(_loadWalkingDistances(_properties));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _schools = _schoolsFromProperties(_properties));
    }
  }

  void _resetWalkingRoutes() {
    _walkingDistanceByPropertyId.clear();
    _walkingMinutesByPropertyId.clear();
    _walkingSchoolByPropertyId.clear();
    _distanceLoadCursor = 0;
    _routeLoadVersion++;
    _propertiesVersion++;
  }

  Future<void> _loadWalkingDistances(List<Property> properties) async {
    final selectedSchool = _selectedSchoolLocation;
    if (selectedSchool == null) return;
    if (_distanceLoadCursor >= properties.length) return;
    final routeLoadVersion = _routeLoadVersion;
    final batch = properties
        .skip(_distanceLoadCursor)
        .take(_distanceBatchSize)
        .toList(growable: false);
    if (batch.isEmpty) return;

    if (_loadingWalkingDistances) return;
    _loadingWalkingDistances = true;

    try {
      final requests = batch
          .map((property) async {
            final closestRoute = await _closestWalkingRoute(
              property,
              selectedSchool,
            );
            if (closestRoute == null || routeLoadVersion != _routeLoadVersion) {
              return;
            }

            _walkingDistanceByPropertyId[property.id] =
                closestRoute.distanceKm;
            _walkingMinutesByPropertyId[property.id] =
                closestRoute.durationMin;
            _walkingSchoolByPropertyId[property.id] = closestRoute.schoolName;
          })
          .toList(growable: false);

      await Future.wait(requests);

      if (!mounted) return;
      if (routeLoadVersion != _routeLoadVersion) return;
      setState(() {
        _distanceLoadCursor += batch.length;
        _propertiesVersion++;
      });
    } finally {
      _loadingWalkingDistances = false;
    }
  }

  Future<void> _loadNextDistanceBatch(List<Property> properties) async {
    await _loadWalkingDistances(properties);
  }

  Future<_ClosestSchoolRoute?> _closestWalkingRoute(
    Property property,
    _SchoolLocation selectedSchool,
  ) async {
    final route = await _routeService.getWalkingSummary(
      fromLat: property.latitude,
      fromLng: property.longitude,
      toLat: selectedSchool.latitude,
      toLng: selectedSchool.longitude,
    );
    final distance = route?.distanceKm;
    final duration = route?.durationMin;
    if (distance == null || duration == null) return null;

    return _ClosestSchoolRoute(
      schoolName: Formatters.schoolName(selectedSchool.name),
      distanceKm: distance,
      durationMin: duration,
    );
  }

  _SchoolLocation? _schoolLocationFromMap(Map<String, dynamic> school) {
    final name = school['name']?.toString().trim();
    final lat = _optionalDouble(school['latitude'] ?? school['lat']);
    final lng = _optionalDouble(school['longitude'] ?? school['lng']);
    if (name == null || name.isEmpty || lat == null || lng == null) {
      return null;
    }
    return _SchoolLocation(
      name: Formatters.schoolName(name),
      latitude: lat,
      longitude: lng,
    );
  }

  _SchoolLocation? get _selectedSchoolLocation {
    final school = _selectedSchool;
    if (school == null) return null;
    return _schoolLocationFromMap(school);
  }

  double? _optionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Future<void> _loadCurrentLocationLabel() async {
    const fallback = 'Lusaka, Zambia';
    try {
      final servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (!servicesEnabled) {
        if (!mounted) return;
        setState(() => _locationLabel = fallback);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _locationLabel = fallback);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String label = fallback;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city =
              (place.locality ??
                      place.subAdministrativeArea ??
                      place.administrativeArea ??
                      '')
                  .trim();
          final country = (place.country ?? 'Zambia').trim();
          if (city.isNotEmpty) {
            label = '$city, $country';
          } else if (country.isNotEmpty) {
            label = country;
          }
        }
      } catch (_) {
        label = fallback;
      }

      if (!mounted) return;
      setState(() => _locationLabel = label);
    } catch (_) {
      if (!mounted) return;
      setState(() => _locationLabel = fallback);
    }
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted || _searchQuery == query) return;
      setState(() => _searchQuery = query);
    });
  }

  List<Property> _getFilteredProperties() {
    final activeFiltersKey = BrowseFilterEngine.buildFiltersKey(
      _selectedFilters,
    );
    if (_cachedVersion == _propertiesVersion &&
        _cachedQuery == _searchQuery &&
        _cachedSchoolId == _selectedSchoolId &&
        _cachedFiltersKey == activeFiltersKey) {
      return _cachedFilteredProperties;
    }

    final searched =
        _searchQuery.isEmpty
            ? _properties
            : _properties
                .where(
                  (p) =>
                      p.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      p.address.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                )
                .toList(growable: false);
    final selectedSchool = _selectedSchool;
    final filtered =
        selectedSchool == null
            ? searched
            : searched
                .where(
                  (property) => _isNearSelectedSchool(property, selectedSchool),
                )
                .toList(growable: false);

    final result = BrowseFilterEngine.applyFilters(
      properties: filtered,
      selectedFilters: _selectedFilters,
      walkingDistanceByPropertyId: _walkingDistanceByPropertyId,
    );
    if (_distanceLoadCursor < _properties.length) {
      unawaited(_loadWalkingDistances(_properties));
    }

    _cachedVersion = _propertiesVersion;
    _cachedQuery = _searchQuery;
    _cachedSchoolId = _selectedSchoolId;
    _cachedFiltersKey = activeFiltersKey;
    _cachedFilteredProperties = result;
    return result;
  }

  Map<String, dynamic>? get _selectedSchool {
    final schoolId = _selectedSchoolId;
    if (schoolId == null) return null;
    for (final school in _availableSchools) {
      if (school['id']?.toString() == schoolId) return school;
    }
    return null;
  }

  List<Map<String, dynamic>> get _availableSchools =>
      _schools.isNotEmpty ? _schools : _schoolsFromProperties(_properties);

  String get _selectedSchoolLabel {
    final school = _selectedSchool;
    if (school == null) return 'All schools';
    final name = school['name']?.toString();
    return name == null ? 'Selected school' : Formatters.schoolName(name);
  }

  bool _isNearSelectedSchool(
    Property property,
    Map<String, dynamic> selectedSchool,
  ) {
    final selectedId = selectedSchool['id']?.toString();
    if (selectedId != null &&
        selectedId.isNotEmpty &&
        property.nearestSchoolId == selectedId) {
      return true;
    }

    final selectedName =
        selectedSchool['name']?.toString().toLowerCase().trim();
    final propertySchool = property.schoolName?.toLowerCase().trim();
    return selectedName != null &&
        selectedName.isNotEmpty &&
        propertySchool != null &&
        propertySchool == selectedName;
  }

  List<Map<String, dynamic>> _schoolsFromProperties(List<Property> properties) {
    final byKey = <String, Map<String, dynamic>>{};
    for (final property in properties) {
      final id = property.nearestSchoolId;
      final name = property.schoolName;
      if ((id == null || id.isEmpty) && (name == null || name.isEmpty)) {
        continue;
      }
      final key = id ?? name!;
      byKey[key] = {
        'id': id ?? name,
        'name': name == null ? 'School' : Formatters.schoolName(name),
        'latitude': property.resolvedSchoolLat,
        'longitude': property.resolvedSchoolLng,
      };
    }
    return byKey.values.toList(growable: false)
      ..sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
  }

  Future<void> _openFiltersSheet() async {
    final picked = await BrowseFiltersSheet.show(
      context: context,
      selectedFilters: _selectedFilters,
    );

    if (picked == null || !mounted) return;
    setState(() {
      _selectedFilters = BrowseFilterEngine.normalizeSelectedFilters(picked);
    });
    if (_distanceLoadCursor < _properties.length) {
      unawaited(_loadWalkingDistances(_properties));
    }
  }

  Future<void> _openSchoolSheet() async {
    final picked = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => SchoolPickerSheet(
            schools: _availableSchools,
            selectedSchoolId: _selectedSchoolId,
            allSchoolsValue: _allSchoolsValue,
          ),
    );

    if (!mounted || picked == null) return;
    final nextSchoolId = picked == _allSchoolsValue ? null : picked;
    if (nextSchoolId == _selectedSchoolId) return;
    setState(() {
      _selectedSchoolId = nextSchoolId;
      _resetWalkingRoutes();
    });
    if (nextSchoolId != null) {
      unawaited(_loadWalkingDistances(_properties));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProperties = _getFilteredProperties();

    return Scaffold(
      backgroundColor: AppDesign.page(context),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          BrowseSearchAppBar(
            locationLabel: _locationLabel,
            onSearchChanged: _onSearchChanged,
            onOpenFilters: _openFiltersSheet,
          ),
          BrowseSchoolSummary(
            selectedSchoolLabel: _selectedSchoolLabel,
            listingCount: filteredProperties.length,
            onSchoolTap: _openSchoolSheet,
          ),
          BrowseResultsSliver(
            isLoading: _isLoading,
            error: _error,
            properties: filteredProperties,
            savedPropertyIds: widget.savedPropertyIds,
            walkingDistanceByPropertyId: _walkingDistanceByPropertyId,
            walkingMinutesByPropertyId: _walkingMinutesByPropertyId,
            walkingSchoolByPropertyId: _walkingSchoolByPropertyId,
            onRetry: _loadProperties,
            onSavedToggle: widget.onSavedToggle,
          ),
        ],
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 700) {
      return;
    }
    if (_distanceLoadCursor < _properties.length) {
      unawaited(_loadWalkingDistances(_properties));
    }
  }
}

class _SchoolLocation {
  const _SchoolLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double latitude;
  final double longitude;
}

class _ClosestSchoolRoute {
  const _ClosestSchoolRoute({
    required this.schoolName,
    required this.distanceKm,
    required this.durationMin,
  });

  final String schoolName;
  final double distanceKm;
  final int durationMin;
}
