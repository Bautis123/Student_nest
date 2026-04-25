import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../services/route_service.dart';
import '../../utils/theme.dart';
import '../../widgets/app_header_background.dart';
import '../../widgets/property_card.dart';
import 'browse/browse_controls.dart';
import 'browse/browse_empty_state.dart';
import 'browse/browse_error_state.dart';
import 'browse/browse_filters.dart';
import 'browse/browse_filters_sheet.dart';
import 'property_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final ApiService _api = ApiService();
  final RouteService _routeService = RouteService();
  final ScrollController _scrollController = ScrollController();
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  Timer? _searchDebounce;
  Set<BrowseFilter> _selectedFilters = {BrowseFilter.suggested};
  final Map<String, double> _walkingDistanceByPropertyId = {};
  bool _loadingWalkingDistances = false;
  int _distanceLoadCursor = 0;
  static const int _distanceBatchSize = 8;
  String _locationLabel = 'Locating...';

  int _propertiesVersion = 0;
  int _cachedVersion = -1;
  String _cachedQuery = '';
  String _cachedFiltersKey = '';
  List<Property> _cachedFilteredProperties = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    unawaited(_loadCurrentLocationLabel());
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
        _distanceLoadCursor = 0;
        _propertiesVersion++;
        _isLoading = false;
      });
      unawaited(_loadNextDistanceBatch(properties));
    } catch (e) {
      setState(() {
        _error = 'Failed to load listings. Check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWalkingDistances(List<Property> properties) async {
    if (_distanceLoadCursor >= properties.length) return;
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
            final schoolLat = property.resolvedSchoolLat;
            final schoolLng = property.resolvedSchoolLng;
            if (schoolLat == null || schoolLng == null) return;

            final distance = await _routeService.getWalkingDistanceKm(
              fromLat: property.latitude,
              fromLng: property.longitude,
              toLat: schoolLat,
              toLng: schoolLng,
            );
            if (distance == null) return;
            _walkingDistanceByPropertyId[property.id] = distance;
          })
          .toList(growable: false);

      await Future.wait(requests);

      if (!mounted) return;
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
        _cachedFiltersKey == activeFiltersKey) {
      return _cachedFilteredProperties;
    }

    final filtered =
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
    _cachedFiltersKey = activeFiltersKey;
    _cachedFilteredProperties = result;
    return result;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProperties = _getFilteredProperties();

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 156,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            scrolledUnderElevation: 0,
            toolbarHeight: 86,
            titleSpacing: 16,
            title: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your Location',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(_locationLabel, style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF63799B).withValues(alpha: 0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      color: Color(0xFF131B2C),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by location or name',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8E96A8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 12, right: 8),
                        child: Icon(
                          Icons.search_rounded,
                          size: 32,
                          color: Color(0xFF667085),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 54,
                        minHeight: 52,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
                        child: Material(
                          color: AppTheme.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: _openFiltersSheet,
                            customBorder: const CircleBorder(),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.tune_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 17),
                    ),
                  ),
                ),
              ),
            ),
            flexibleSpace: const AppHeaderBackground(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BrowseFilterButton(onTap: _openFiltersSheet),
                      const SizedBox(width: 16),
                      Container(
                        width: 1,
                        height: 32,
                        color: const Color(0xFFD6DCE8),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BrowseCountPill(
                          label: '${filteredProperties.length} boarding houses',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: BrowseErrorState(
                message: _error!,
                onRetry: _loadProperties,
              ),
            )
          else if (filteredProperties.isEmpty)
            const SliverFillRemaining(child: BrowseEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final property = filteredProperties[index];
                  return PropertyCard(
                    key: ValueKey(property.id),
                    property: property,
                    displayDistanceKm:
                        _walkingDistanceByPropertyId[property.id],
                    preferWalkingDistance: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  PropertyDetailScreen(propertyId: property.id),
                        ),
                      );
                    },
                  );
                }, childCount: filteredProperties.length),
              ),
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
