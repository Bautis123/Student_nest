import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../services/route_service.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/sn_loading_indicator.dart';
import 'property_detail/photo_gallery_screen.dart';
import 'property_detail/property_action_bar.dart';
import 'property_detail/property_detail_sections.dart';
import 'property_detail/property_intro_section.dart';
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
    await _routeActions.openInMaps(context: context, property: _property!);
  }

  Future<void> _openInYango() async {
    if (_property == null) return;
    await _routeActions.openInYango(context: context, property: _property!);
  }

  void _viewAllPhotos() {
    final p = _property!;
    if (p.photos.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoGalleryScreen(photos: p.photos, title: p.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: SNLoadingIndicator());
    }

    if (_property == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Property'),
          backgroundColor: AppDesign.surface(context),
          foregroundColor: AppDesign.text(context),
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
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
    final photoCount = p.photos.length;

    return Scaffold(
      backgroundColor: AppDesign.page(context),
      body: Stack(
        children: [
          const _SoftBackground(),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.paddingOf(context).top + 20,
                16,
                190,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TopButtons(),
                  const SizedBox(height: 20),
                  _PropertyPhotoHero(
                    coverPhoto: coverPhoto,
                    photoCount: photoCount,
                    onTap: p.photos.isNotEmpty ? _viewAllPhotos : null,
                  ),
                  const SizedBox(height: 14),
                  _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PropertyIntroSection(
                          property: p,
                          walkingDistanceKm: _walkingDistanceKm,
                        ),
                        const SizedBox(height: 22),
                        PropertyAmenitiesSection(property: p),
                        if (p.rooms.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          PropertyRoomsSection(property: p),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PropertyActionBar(
              onOpenMaps: _openInMaps,
              onOpenYango: _openInYango,
              onCall: _callLandlord,
              landlordName: p.landlordName ?? 'Landlord',
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftBackground extends StatelessWidget {
  const _SoftBackground();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppDesign.page(context),
      child: SizedBox.expand(),
    );
  }
}

class _TopButtons extends StatelessWidget {
  const _TopButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RoundIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        _RoundIconButton(icon: Icons.favorite_border_rounded, onTap: () {}),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppDesign.surface(context),
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppDesign.text(context), size: 22),
        ),
      ),
    );
  }
}

class _PropertyPhotoHero extends StatelessWidget {
  const _PropertyPhotoHero({
    required this.coverPhoto,
    required this.photoCount,
    this.onTap,
  });

  final Photo? coverPhoto;
  final int photoCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: AppDesign.accentTint(context),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (coverPhoto != null)
                  CachedNetworkImage(
                    imageUrl: coverPhoto!.cacheAwareUrl,
                    fit: BoxFit.cover,
                    placeholder:
                        (_, __) => Container(
                          color: AppDesign.accentTint(context),
                        ),
                    errorWidget: (_, __, ___) => const _PhotoFallback(),
                  )
                else
                  const _PhotoFallback(),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.65),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          color: AppColors.white,
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$photoCount photo${photoCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.home_work_outlined, size: 64, color: AppDesign.accent),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppDesign.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppDesign.border(context)),
      ),
      child: child,
    );
  }
}
