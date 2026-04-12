import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import 'property_detail/photo_gallery_screen.dart';
import 'property_detail/property_action_bar.dart';
import 'property_detail/property_amenity_tile.dart';
import 'property_detail/property_cover_app_bar.dart';
import 'property_detail/property_intro_section.dart';
import 'property_detail/property_landlord_card.dart';
import 'property_detail/property_photos_section.dart';
import 'property_detail/property_route_map_sheet.dart';
import 'property_detail/property_room_row.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final ApiService _api = ApiService();
  Property? _property;
  double? _walkingDistanceKm;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      final property = await _api.getPropertyById(widget.propertyId);
      final walkingDistance = await _fetchWalkingDistanceKm(property);
      setState(() {
        _property = property;
        _walkingDistanceKm = walkingDistance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<double?> _fetchWalkingDistanceKm(Property property) async {
    final schoolLat = property.resolvedSchoolLat;
    final schoolLng = property.resolvedSchoolLng;
    if (schoolLat == null || schoolLng == null) return null;

    final origin = '${property.longitude},${property.latitude}';
    final destination = '$schoolLng,$schoolLat';
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

  Future<void> _callLandlord() async {
    if (_property?.landlordPhone == null) return;
    await _api.trackContactClick(widget.propertyId);
    final uri = Uri.parse('tel:${_property!.landlordPhone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _viewInMap() {
    if (_property == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: PropertyRouteMapSheet(property: _property!),
      ),
    );
  }

  void _viewAllPhotos() {
    final p = _property!;
    final otherPhotos = p.photos.where((ph) => !ph.isCover).toList();
    if (otherPhotos.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoGalleryScreen(photos: otherPhotos, title: p.title),
      ),
    );
  }

  Widget _buildAmenities(Property p) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        PropertyAmenityTile(
          label: 'WiFi',
          icon: Icons.wifi,
          available: p.amenities['wifi'] == true,
        ),
        PropertyAmenityTile(
          label: 'Water',
          icon: Icons.water_drop_outlined,
          available: p.amenities['water'] == true,
        ),
        PropertyAmenityTile(
          label: 'Electricity',
          icon: Icons.bolt_outlined,
          available: p.amenities['electricity'] == true,
        ),
        PropertyAmenityTile(
          label: 'Security',
          icon: Icons.security_outlined,
          available: p.amenities['security'] == true,
        ),
      ],
    );
  }

  Widget _buildRooms(Property p) {
    if (p.rooms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Types',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 10),
        ...p.rooms.map((room) => PropertyRoomRow(room: room)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property')),
        body: const Center(child: Text('Property not found')),
      );
    }

    final p = _property!;
    final coverPhoto =
        p.photos.isNotEmpty
            ? p.photos.firstWhere(
              (ph) => ph.isCover,
              orElse: () => p.photos.first,
            )
            : null;
    final otherPhotos =
        p.photos.where((ph) => ph.id != coverPhoto?.id).toList();

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: CustomScrollView(
        slivers: [
          PropertyCoverAppBar(coverPhoto: coverPhoto),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PropertyIntroSection(
                    property: p,
                    walkingDistanceKm: _walkingDistanceKm,
                  ),
                  if (otherPhotos.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    PropertyPhotosSection(
                      photos: otherPhotos,
                      onViewAll: _viewAllPhotos,
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.dark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildAmenities(p),
                  if (p.rooms.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildRooms(p),
                  ],
                  const SizedBox(height: 20),
                  PropertyLandlordCard(property: p),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PropertyActionBar(
        onViewMap: _viewInMap,
        onCall: _callLandlord,
        landlordName: p.landlordName ?? 'Landlord',
      ),
    );
  }
}
