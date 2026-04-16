import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../services/route_service.dart';
import '../../utils/theme.dart';
import '../../widgets/app_header_background.dart';
import 'property_detail/photo_gallery_screen.dart';
import 'property_detail/property_action_bar.dart';
import 'property_detail/property_cover_app_bar.dart';
import 'property_detail/property_detail_sections.dart';
import 'property_detail/property_intro_section.dart';
import 'property_detail/property_landlord_card.dart';
import 'property_detail/property_photos_section.dart';
import 'property_detail/property_route_actions.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final ApiService _api = ApiService();
  final RouteService _routeService = RouteService();
  final PropertyRouteActions _routeActions = const PropertyRouteActions();
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

    try {
      return await _routeService.getWalkingDistanceKm(
        fromLat: property.latitude,
        fromLng: property.longitude,
        toLat: schoolLat,
        toLng: schoolLng,
      );
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

  Future<void> _openInMaps() async {
    if (_property == null) return;
    await _routeActions.openInMaps(
      context: context,
      property: _property!,
    );
  }

  Future<void> _openInYango() async {
    if (_property == null) return;
    await _routeActions.openInYango(
      context: context,
      property: _property!,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_property == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Property'),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: const AppHeaderBackground(),
        ),
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
                  PropertyAmenitiesSection(property: p),
                  if (p.rooms.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    PropertyRoomsSection(property: p),
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
        onOpenMaps: _openInMaps,
        onOpenYango: _openInYango,
        onCall: _callLandlord,
        landlordName: p.landlordName ?? 'Landlord',
      ),
    );
  }
}
