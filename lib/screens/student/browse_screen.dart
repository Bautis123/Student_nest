import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../widgets/property_card.dart';
import 'property_detail_screen.dart';

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

  int _propertiesVersion = 0;
  int _cachedVersion = -1;
  String _cachedQuery = '';
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
    } catch (e) {
      setState(() {
        _error = 'Failed to load listings. Check your connection.';
        _isLoading = false;
      });
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
    if (_cachedVersion == _propertiesVersion && _cachedQuery == _searchQuery) {
      return _cachedFilteredProperties;
    }

    final filtered = _searchQuery.isEmpty
        ? _properties
        : _properties
            .where(
              (p) =>
                  p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  p.address.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList(growable: false);

    final result = _buildSuggestedOrder(filtered);

    _cachedVersion = _propertiesVersion;
    _cachedQuery = _searchQuery;
    _cachedFilteredProperties = result;
    return result;
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
      (p) => p.isPremium && p.distanceFromSchool != null,
      (a, b) => a.distanceFromSchool!.compareTo(b.distanceFromSchool!),
    ); // 1. Closest premium
    takeBest(
      (p) => !p.isPremium && p.distanceFromSchool != null,
      (a, b) => a.distanceFromSchool!.compareTo(b.distanceFromSchool!),
    ); // 2. Closest basic
    takeBest(
      (p) => p.isPremium && p.distanceFromSchool != null,
      (a, b) => b.distanceFromSchool!.compareTo(a.distanceFromSchool!),
    ); // 3. Furthest premium
    takeBest(
      (_) => true,
      (a, b) {
        final clickCompare = b.contactClickCount.compareTo(a.contactClickCount);
        if (clickCompare != 0) return clickCompare;
        return b.viewCount.compareTo(a.viewCount);
      },
    ); // 4. Most clicked
    takeBest(
      (p) => !p.isPremium && p.distanceFromSchool != null,
      (a, b) => b.distanceFromSchool!.compareTo(a.distanceFromSchool!),
    ); // 5. Furthest basic

    remaining.sort((a, b) {
      final aDistance = a.distanceFromSchool;
      final bDistance = b.distanceFromSchool;
      if (aDistance == null && bDistance == null) {
        return b.contactClickCount.compareTo(a.contactClickCount);
      }
      if (aDistance == null) return 1;
      if (bDistance == null) return -1;
      return aDistance.compareTo(bDistance);
    });

    return [...ordered, ...remaining];
  }

  String? _coverUrlFor(Property? property) {
    if (property == null || property.photos.isEmpty) return null;
    final cover = property.photos.firstWhere(
      (p) => p.isCover,
      orElse: () => property.photos.first,
    );
    return cover.url;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProperties = _getFilteredProperties();
    final featuredCoverUrl = _coverUrlFor(
      filteredProperties.isNotEmpty ? filteredProperties.first : null,
    );

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (featuredCoverUrl != null)
                    CachedNetworkImage(
                      imageUrl: featuredCoverUrl,
                      fit: BoxFit.cover,
                      memCacheHeight: 560,
                      maxHeightDiskCache: 1080,
                      placeholder:
                          (_, __) => Container(color: AppTheme.primaryLight),
                      errorWidget:
                          (_, __, ___) => Container(color: AppTheme.primary),
                    )
                  else
                    Container(color: AppTheme.primary),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Student Nest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 8, color: Colors.black45),
                            ],
                          ),
                        ),
                        const Text(
                          'Find boarding houses near UNZA',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Spacer(),
                        TextField(
                          onChanged: _onSearchChanged,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search by name or area...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(Icons.search, size: 20),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
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
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final property = filteredProperties[index];
                  return PropertyCard(
                    key: ValueKey(property.id),
                    property: property,
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
