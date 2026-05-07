import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../services/route_service.dart';
import '../../utils/app_design.dart';
import '../../utils/student_nest_icons.dart';
import '../../widgets/property_card.dart';
import 'browse/browse_empty_state.dart';
import 'browse/browse_error_state.dart';
import 'browse/browse_filters.dart';
import 'browse/browse_filters_sheet.dart';
import 'property_detail_screen.dart';

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
  bool _loadingWalkingDistances = false;
  int _distanceLoadCursor = 0;
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
        _distanceLoadCursor = 0;
        _propertiesVersion++;
        _isLoading = false;
      });
      widget.onPropertiesLoaded?.call(properties);
      unawaited(_loadNextDistanceBatch(properties));
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
    setState(() => _selectedSchoolId = schoolId);
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await _api.getSchools();
      if (!mounted) return;
      setState(() => _schools = schools);
    } catch (_) {
      if (!mounted) return;
      setState(() => _schools = _schoolsFromProperties(_properties));
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
                .where((property) => _isNearSelectedSchool(property, selectedSchool))
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
    return school['name']?.toString() ?? 'Selected school';
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

    final selectedName = selectedSchool['name']?.toString().toLowerCase().trim();
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
        'name': name ?? 'School',
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
          (_) => _SchoolPickerSheet(
            schools: _availableSchools,
            selectedSchoolId: _selectedSchoolId,
            allSchoolsValue: _allSchoolsValue,
          ),
    );

    if (!mounted || picked == null) return;
    final nextSchoolId = picked == _allSchoolsValue ? null : picked;
    if (nextSchoolId == _selectedSchoolId) return;
    setState(() => _selectedSchoolId = nextSchoolId);
  }

  @override
  Widget build(BuildContext context) {
    final filteredProperties = _getFilteredProperties();

    return Scaffold(
      backgroundColor: AppDesign.page(context),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 126,
            floating: false,
            pinned: true,
            backgroundColor: AppDesign.surface(context),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
            toolbarHeight: 62,
            titleSpacing: 16,
            title: Row(
              children: [
                const StudentNestIcon(
                  StudentNestIcons.mapPin,
                  size: 15,
                  color: AppDesign.accent,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppDesign.muted(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppDesign.subtle(context),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: ColoredBox(
                color: AppDesign.surface(context),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppDesign.surface(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppDesign.shadow(context),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        color: AppDesign.text(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by location or name',
                        hintStyle: TextStyle(
                          color: AppDesign.muted(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: Icon(
                            Icons.search_rounded,
                            size: 32,
                            color: AppDesign.muted(context),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 54,
                          minHeight: 52,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
                          child: Material(
                            color: AppDesign.accent,
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _SchoolSelectorButton(
                      label: _selectedSchoolLabel,
                      onTap: _openSchoolSheet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      '${filteredProperties.length} boarding houses',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppDesign.muted(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
                    isSaved: widget.savedPropertyIds.contains(property.id),
                    onSavedChanged:
                        (isSaved) =>
                            widget.onSavedToggle?.call(property, isSaved),
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

class _SchoolSelectorButton extends StatelessWidget {
  const _SchoolSelectorButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppDesign.surface(context),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppDesign.border(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StudentNestIcon(
                StudentNestIcons.university,
                size: 16,
                color: AppDesign.accent,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppDesign.text(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppDesign.subtle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchoolPickerSheet extends StatelessWidget {
  const _SchoolPickerSheet({
    required this.schools,
    required this.selectedSchoolId,
    required this.allSchoolsValue,
  });

  final List<Map<String, dynamic>> schools;
  final String? selectedSchoolId;
  final String allSchoolsValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesign.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppDesign.border(context),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select school',
              style: TextStyle(
                color: AppDesign.text(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _SchoolOption(
              title: 'All schools',
              subtitle: 'Show every boarding house',
              isSelected: selectedSchoolId == null,
              onTap: () => Navigator.pop(context, allSchoolsValue),
            ),
            for (final school in schools)
              _SchoolOption(
                title: school['name']?.toString() ?? 'School',
                subtitle: school['area']?.toString() ?? 'Nearby listings',
                isSelected: selectedSchoolId == school['id']?.toString(),
                onTap: () => Navigator.pop(context, school['id']?.toString()),
              ),
          ],
        ),
      ),
    );
  }
}

class _SchoolOption extends StatelessWidget {
  const _SchoolOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppDesign.surface(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppDesign.accentTint(context)
                          : AppDesign.page(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: StudentNestIcon(
                  StudentNestIcons.university,
                  size: 17,
                  color:
                      isSelected
                          ? AppDesign.accent
                          : AppDesign.muted(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppDesign.text(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppDesign.muted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppDesign.accent,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
