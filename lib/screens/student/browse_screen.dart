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
import 'property_detail_screen.dart';

enum BrowseFilter {
  suggested('Suggested'),
  closest('Closest'),
  cheapest('Cheapest'),
  mostClicked('Most Clicked'),
  premiumOnly('Premium'),
  basicOnly('Basic');

  const BrowseFilter(this.label);
  final String label;
}

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
  BrowseFilter _browseFilter = BrowseFilter.closest;
  final Map<String, double> _walkingDistanceByPropertyId = {};
  bool _loadingWalkingDistances = false;
  int _distanceLoadCursor = 0;
  static const int _distanceBatchSize = 8;
  String _locationLabel = 'Locating...';

  int _propertiesVersion = 0;
  int _cachedVersion = -1;
  String _cachedQuery = '';
  BrowseFilter _cachedFilter = BrowseFilter.closest;
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
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
              (place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? '')
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
    if (_cachedVersion == _propertiesVersion &&
        _cachedQuery == _searchQuery &&
        _cachedFilter == _browseFilter) {
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

    final result = _applyBrowseFilter(filtered);
    if (_distanceLoadCursor < _properties.length) {
      unawaited(_loadWalkingDistances(_properties));
    }

    _cachedVersion = _propertiesVersion;
    _cachedQuery = _searchQuery;
    _cachedFilter = _browseFilter;
    _cachedFilteredProperties = result;
    return result;
  }

  List<Property> _applyBrowseFilter(List<Property> properties) {
    final sortKeys = _buildSortKeys(properties);

    switch (_browseFilter) {
      case BrowseFilter.suggested:
        return _buildSuggestedOrder(properties, sortKeys);
      case BrowseFilter.closest:
        final sorted = List<Property>.from(properties);
        sorted.sort((a, b) {
          final aDistance = sortKeys[a.id]?.distanceKm;
          final bDistance = sortKeys[b.id]?.distanceKm;
          if (aDistance == null && bDistance == null) return 0;
          if (aDistance == null) return 1;
          if (bDistance == null) return -1;
          return aDistance.compareTo(bDistance);
        });
        return sorted;
      case BrowseFilter.cheapest:
        final sorted = List<Property>.from(properties);
        sorted.sort((a, b) {
          final aPrice = sortKeys[a.id]?.price;
          final bPrice = sortKeys[b.id]?.price;
          if (aPrice == null && bPrice == null) return 0;
          if (aPrice == null) return 1;
          if (bPrice == null) return -1;
          return aPrice.compareTo(bPrice);
        });
        return sorted;
      case BrowseFilter.mostClicked:
        final sorted = List<Property>.from(properties);
        sorted.sort((a, b) {
          final clickCompare = (sortKeys[b.id]?.clicks ?? 0).compareTo(
            sortKeys[a.id]?.clicks ?? 0,
          );
          if (clickCompare != 0) return clickCompare;
          return (sortKeys[b.id]?.views ?? 0).compareTo(
            sortKeys[a.id]?.views ?? 0,
          );
        });
        return sorted;
      case BrowseFilter.premiumOnly:
        final filtered = properties
            .where((p) => p.isPremium)
            .toList(growable: false);
        return _buildSuggestedOrder(filtered, sortKeys);
      case BrowseFilter.basicOnly:
        final filtered = properties
            .where((p) => !p.isPremium)
            .toList(growable: false);
        return _buildSuggestedOrder(filtered, sortKeys);
    }
  }

  Map<String, _BrowseSortKey> _buildSortKeys(List<Property> properties) {
    final keys = <String, _BrowseSortKey>{};
    for (final property in properties) {
      keys[property.id] = _BrowseSortKey(
        distanceKm:
            _walkingDistanceByPropertyId[property.id] ??
            property.straightLineDistanceKm,
        price: property.minPrice,
        clicks: property.contactClickCount,
        views: property.viewCount,
      );
    }
    return keys;
  }

  Widget _filterBar() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: BrowseFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = BrowseFilter.values[index];
          final selected = filter == _browseFilter;
          return ChoiceChip(
            label: Text(filter.label),
            selected: selected,
            onSelected: (_) {
              setState(() => _browseFilter = filter);
              if (_distanceLoadCursor < _properties.length) {
                unawaited(_loadWalkingDistances(_properties));
              }
            },
            selectedColor: AppTheme.primary.withValues(alpha: 0.18),
            labelStyle: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.gray,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
            side: BorderSide(
              color:
                  selected
                      ? AppTheme.primary.withValues(alpha: 0.45)
                      : AppTheme.border,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            showCheckmark: false,
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          );
        },
      ),
    );
  }

  List<Property> _buildSuggestedOrder(
    List<Property> properties,
    Map<String, _BrowseSortKey> sortKeys,
  ) {
    if (properties.length <= 1) return properties;

    final remaining = List<Property>.from(properties);
    final ordered = <Property>[];

    void takeBest(
      bool Function(Property property) predicate,
      int Function(Property a, Property b) comparator,
    ) {
      final candidates = remaining.where(predicate).toList(growable: false);
      if (candidates.isEmpty) return;
      candidates.sort(comparator);
      final selected = candidates.first;
      ordered.add(selected);
      remaining.removeWhere((p) => p.id == selected.id);
    }

    takeBest(
      (p) => p.isPremium && sortKeys[p.id]?.distanceKm != null,
      (a, b) =>
          sortKeys[a.id]!.distanceKm!.compareTo(sortKeys[b.id]!.distanceKm!),
    ); // 1. Closest premium
    takeBest(
      (p) => !p.isPremium && sortKeys[p.id]?.distanceKm != null,
      (a, b) =>
          sortKeys[a.id]!.distanceKm!.compareTo(sortKeys[b.id]!.distanceKm!),
    ); // 2. Closest basic
    takeBest(
      (p) => p.isPremium && sortKeys[p.id]?.distanceKm != null,
      (a, b) =>
          sortKeys[b.id]!.distanceKm!.compareTo(sortKeys[a.id]!.distanceKm!),
    ); // 3. Furthest premium
    takeBest((_) => true, (a, b) {
      final clickCompare = sortKeys[b.id]!.clicks.compareTo(
        sortKeys[a.id]!.clicks,
      );
      if (clickCompare != 0) return clickCompare;
      return sortKeys[b.id]!.views.compareTo(sortKeys[a.id]!.views);
    }); // 4. Most clicked
    takeBest(
      (p) => !p.isPremium && sortKeys[p.id]?.distanceKm != null,
      (a, b) =>
          sortKeys[b.id]!.distanceKm!.compareTo(sortKeys[a.id]!.distanceKm!),
    ); // 5. Furthest basic

    remaining.sort((a, b) {
      final aDistance = sortKeys[a.id]?.distanceKm;
      final bDistance = sortKeys[b.id]?.distanceKm;
      if (aDistance == null && bDistance == null) {
        return sortKeys[b.id]!.clicks.compareTo(sortKeys[a.id]!.clicks);
      }
      if (aDistance == null) return 1;
      if (bDistance == null) return -1;
      return aDistance.compareTo(bDistance);
    });

    return [...ordered, ...remaining];
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Location',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  _locationLabel,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: _onSearchChanged,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search_rounded, size: 22),
                    filled: true,
                    fillColor: AppTheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),
            flexibleSpace: const AppHeaderBackground(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
              child: _filterBar(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  _QuickPill(
                    icon: Icons.home_work_outlined,
                    label: '${filteredProperties.length} listings',
                  ),
                  const SizedBox(width: 8),
                  _QuickPill(
                    icon: Icons.explore_outlined,
                    label: _browseFilter.label,
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: AppTheme.gray),
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppTheme.gray)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProperties,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(160, 44),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredProperties.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: 48,
                      color: AppTheme.gray,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No listings found',
                      style: TextStyle(color: AppTheme.gray),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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

class _QuickPill extends StatelessWidget {
  const _QuickPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowseSortKey {
  final double? distanceKm;
  final double? price;
  final int clicks;
  final int views;

  const _BrowseSortKey({
    required this.distanceKm,
    required this.price,
    required this.clicks,
    required this.views,
  });
}
