import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
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
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  Timer? _searchDebounce;
  BrowseFilter _browseFilter = BrowseFilter.closest;
  final Map<String, double> _walkingDistanceByPropertyId = {};
  bool _loadingWalkingDistances = false;

  int _propertiesVersion = 0;
  int _cachedVersion = -1;
  String _cachedQuery = '';
  BrowseFilter _cachedFilter = BrowseFilter.closest;
  List<Property> _cachedFilteredProperties = const [];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
        _propertiesVersion++;
        _isLoading = false;
      });
      unawaited(_loadWalkingDistances(properties));
    } catch (e) {
      setState(() {
        _error = 'Failed to load listings. Check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWalkingDistances(List<Property> properties) async {
    if (_loadingWalkingDistances) return;
    _loadingWalkingDistances = true;

    try {
      final requests = properties
          .take(30)
          .map((property) async {
            final schoolLat = property.resolvedSchoolLat;
            final schoolLng = property.resolvedSchoolLng;
            if (schoolLat == null || schoolLng == null) return;

            final distance = await _fetchWalkingDistanceKm(
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
        _propertiesVersion++;
      });
    } finally {
      _loadingWalkingDistances = false;
    }
  }

  Future<double?> _fetchWalkingDistanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final origin = '$fromLng,$fromLat';
    final destination = '$toLng,$toLat';
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/walking/$origin;$destination'
      '?overview=false',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if ((data['code']?.toString().toLowerCase() ?? '') != 'ok') return null;
      final routes = data['routes'] as List<dynamic>? ?? const [];
      if (routes.isEmpty) return null;
      final distanceMeters = (routes.first as Map<String, dynamic>)['distance'] as num?;
      if (distanceMeters == null) return null;
      return distanceMeters.toDouble() / 1000;
    } catch (_) {
      return null;
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

    _cachedVersion = _propertiesVersion;
    _cachedQuery = _searchQuery;
    _cachedFilter = _browseFilter;
    _cachedFilteredProperties = result;
    return result;
  }

  List<Property> _applyBrowseFilter(List<Property> properties) {
    switch (_browseFilter) {
      case BrowseFilter.suggested:
        return _buildSuggestedOrder(properties);
      case BrowseFilter.closest:
        final sorted = List<Property>.from(properties);
        sorted.sort((a, b) {
          final aDistance =
              _walkingDistanceByPropertyId[a.id] ?? a.straightLineDistanceKm;
          final bDistance =
              _walkingDistanceByPropertyId[b.id] ?? b.straightLineDistanceKm;
          if (aDistance == null && bDistance == null) return 0;
          if (aDistance == null) return 1;
          if (bDistance == null) return -1;
          return aDistance.compareTo(bDistance);
        });
        return sorted;
      case BrowseFilter.cheapest:
        final sorted = List<Property>.from(properties);
        sorted.sort((a, b) {
          final aPrice = a.minPrice;
          final bPrice = b.minPrice;
          if (aPrice == null && bPrice == null) return 0;
          if (aPrice == null) return 1;
          if (bPrice == null) return -1;
          return aPrice.compareTo(bPrice);
        });
        return sorted;
      case BrowseFilter.mostClicked:
        final sorted = List<Property>.from(properties);
        sorted.sort((a, b) {
          final clickCompare = b.contactClickCount.compareTo(a.contactClickCount);
          if (clickCompare != 0) return clickCompare;
          return b.viewCount.compareTo(a.viewCount);
        });
        return sorted;
      case BrowseFilter.premiumOnly:
        final filtered = properties.where((p) => p.isPremium).toList(growable: false);
        return _buildSuggestedOrder(filtered);
      case BrowseFilter.basicOnly:
        final filtered = properties.where((p) => !p.isPremium).toList(growable: false);
        return _buildSuggestedOrder(filtered);
    }
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
            onSelected: (_) => setState(() => _browseFilter = filter),
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

  List<Property> _buildSuggestedOrder(List<Property> properties) {
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
      (p) => p.isPremium && p.straightLineDistanceKm != null,
      (a, b) => a.straightLineDistanceKm!.compareTo(b.straightLineDistanceKm!),
    ); // 1. Closest premium
    takeBest(
      (p) => !p.isPremium && p.straightLineDistanceKm != null,
      (a, b) => a.straightLineDistanceKm!.compareTo(b.straightLineDistanceKm!),
    ); // 2. Closest basic
    takeBest(
      (p) => p.isPremium && p.straightLineDistanceKm != null,
      (a, b) => b.straightLineDistanceKm!.compareTo(a.straightLineDistanceKm!),
    ); // 3. Furthest premium
    takeBest((_) => true, (a, b) {
      final clickCompare = b.contactClickCount.compareTo(a.contactClickCount);
      if (clickCompare != 0) return clickCompare;
      return b.viewCount.compareTo(a.viewCount);
    }); // 4. Most clicked
    takeBest(
      (p) => !p.isPremium && p.straightLineDistanceKm != null,
      (a, b) => b.straightLineDistanceKm!.compareTo(a.straightLineDistanceKm!),
    ); // 5. Furthest basic

    remaining.sort((a, b) {
      final aDistance = a.straightLineDistanceKm;
      final bDistance = b.straightLineDistanceKm;
      if (aDistance == null && bDistance == null) {
        return b.contactClickCount.compareTo(a.contactClickCount);
      }
      if (aDistance == null) return 1;
      if (bDistance == null) return -1;
      return aDistance.compareTo(bDistance);
    });

    return [...ordered, ...remaining];
  }

  @override
  Widget build(BuildContext context) {
    final filteredProperties = _getFilteredProperties();

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            scrolledUnderElevation: 0,
            toolbarHeight: 68,
            titleSpacing: 16,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Student Nest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Find boarding houses near UNZA',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: _onSearchChanged,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name or area...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            flexibleSpace: Container(color: AppTheme.primary),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _filterBar(),
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
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final property = filteredProperties[index];
                  return PropertyCard(
                    key: ValueKey(property.id),
                    property: property,
                    displayDistanceKm: _walkingDistanceByPropertyId[property.id],
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
}
