import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../services/route_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/app_header_background.dart';
import 'property_detail/photo_gallery_screen.dart';
import 'property_detail/property_action_bar.dart';
import 'property_detail/property_amenity_tile.dart';
import 'property_detail/property_cover_app_bar.dart';
import 'property_detail/property_intro_section.dart';
import 'property_detail/property_landlord_card.dart';
import 'property_detail/property_photos_section.dart';
import 'property_detail/property_room_row.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final ApiService _api = ApiService();
  final RouteService _routeService = RouteService();
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

  String _formatCoord(double value) => value.toStringAsFixed(6);

  Future<void> _openInMaps() async {
    if (_property == null) return;

    final property = _property!;
    final originLat = property.latitude;
    final originLng = property.longitude;
    final destinationLat = property.resolvedSchoolLat ?? AppConstants.defaultLat;
    final destinationLng = property.resolvedSchoolLng ?? AppConstants.defaultLng;

    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIos) {
      _showIosMapsPicker(
        originLat: originLat,
        originLng: originLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
      );
      return;
    }

    await _launchExternalUrl(
      Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${_formatCoord(originLat)},${_formatCoord(originLng)}'
        '&destination=${_formatCoord(destinationLat)},${_formatCoord(destinationLng)}'
        '&travelmode=walking',
      ),
    );
  }

  Future<void> _openInYango() async {
    if (_property == null) return;
    try {
      final hasLocation = await Geolocator.isLocationServiceEnabled();
      if (!hasLocation) {
        _showInfo('Location services are off. Turn them on and try again.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _showInfo('Location permission denied.');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showInfo('Location permission denied forever. Enable it in settings.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final destinationLat = _property!.latitude;
      final destinationLng = _property!.longitude;
      final startLat = position.latitude;
      final startLng = position.longitude;

      final yangoAppUri = Uri.parse(
        'yandextaxi://route?'
        'start-lat=${_formatCoord(startLat)}&'
        'start-lon=${_formatCoord(startLng)}&'
        'end-lat=${_formatCoord(destinationLat)}&'
        'end-lon=${_formatCoord(destinationLng)}&'
        'tariffClass=econom',
      );

      final yangoWebUri = Uri.https('3.redirect.appmetrica.yandex.com', '/route', {
        'start-lat': _formatCoord(startLat),
        'start-lon': _formatCoord(startLng),
        'end-lat': _formatCoord(destinationLat),
        'end-lon': _formatCoord(destinationLng),
        'tariffClass': 'econom',
        'ref': 'studentnest',
        'lang': 'en',
        'appmetrica_tracking_id': '1178268795219780156',
      });

      if (await canLaunchUrl(yangoAppUri)) {
        await _launchExternalUrl(yangoAppUri);
      } else {
        await _launchExternalUrl(yangoWebUri);
      }
    } catch (_) {
      _showInfo('Could not get your current location right now.');
    }
  }

  Future<void> _launchExternalUrl(Uri uri) async {
    final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!didLaunch && mounted) {
      _showInfo('Could not open the app right now.');
    }
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showIosMapsPicker({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) {
    final appleMapsUri = Uri.parse(
      'http://maps.apple.com/?saddr=${_formatCoord(originLat)},${_formatCoord(originLng)}'
      '&daddr=${_formatCoord(destinationLat)},${_formatCoord(destinationLng)}'
      '&dirflg=w',
    );
    final googleMapsUri = Uri.parse(
      'comgooglemaps://?saddr=${_formatCoord(originLat)},${_formatCoord(originLng)}'
      '&daddr=${_formatCoord(destinationLat)},${_formatCoord(destinationLng)}'
      '&directionsmode=walking',
    );

    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Apple Maps'),
                onTap: () async {
                  Navigator.pop(context);
                  await _launchExternalUrl(appleMapsUri);
                },
              ),
              FutureBuilder<bool>(
                future: canLaunchUrl(googleMapsUri),
                builder: (context, snapshot) {
                  if (snapshot.data != true) return const SizedBox.shrink();
                  return ListTile(
                    leading: const Icon(Icons.map_outlined),
                    title: const Text('Google Maps'),
                    onTap: () async {
                      Navigator.pop(context);
                      await _launchExternalUrl(googleMapsUri);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
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
        onOpenMaps: _openInMaps,
        onOpenYango: _openInYango,
        onCall: _callLandlord,
        landlordName: p.landlordName ?? 'Landlord',
      ),
    );
  }
}
