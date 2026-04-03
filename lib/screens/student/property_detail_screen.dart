import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final ApiService _api = ApiService();
  Property? _property;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      final property = await _api.getPropertyById(widget.propertyId);
      setState(() {
        _property = property;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _callLandlord() async {
    if (_property?.landlordPhone == null) return;
    await _api.trackContactClick(widget.propertyId);
    final uri = Uri.parse('tel:${_property!.landlordPhone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _viewAllPhotos() {
    final p = _property!;
    final otherPhotos = p.photos.where((ph) => !ph.isCover).toList();
    if (otherPhotos.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => _PhotoGalleryScreen(photos: otherPhotos, title: p.title),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Hero cover photo
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background:
                  coverPhoto != null
                      ? CachedNetworkImage(
                        imageUrl: coverPhoto.url,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => Container(color: AppTheme.primaryLight),
                        errorWidget:
                            (_, __, ___) => Container(
                              color: AppTheme.primaryLight,
                              child: const Icon(
                                Icons.home_work_outlined,
                                size: 64,
                                color: AppTheme.primary,
                              ),
                            ),
                      )
                      : Container(
                        color: AppTheme.primaryLight,
                        child: const Icon(
                          Icons.home_work_outlined,
                          size: 64,
                          color: AppTheme.primary,
                        ),
                      ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.dark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Distance badge
                  if (p.distanceFromSchool != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 14,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${p.distanceFromSchool!.toStringAsFixed(2)} km from ${p.schoolName ?? 'UNZA'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Address
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.gray,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          p.address,
                          style: const TextStyle(
                            color: AppTheme.gray,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (p.description != null && p.description!.isNotEmpty) ...[
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // View Photos block
                  if (otherPhotos.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Photos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.dark,
                          ),
                        ),
                        GestureDetector(
                          onTap: _viewAllPhotos,
                          child: Text(
                            'View all ${otherPhotos.length} photos',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            otherPhotos.length > 4 ? 4 : otherPhotos.length,
                        itemBuilder: (_, i) {
                          final isLast = i == 3 && otherPhotos.length > 4;
                          return GestureDetector(
                            onTap: _viewAllPhotos,
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: otherPhotos[i].url,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (isLast)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        color: Colors.black.withOpacity(0.5),
                                        child: Center(
                                          child: Text(
                                            '+${otherPhotos.length - 3}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Amenities
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.dark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _amenityTile(
                        'WiFi',
                        Icons.wifi,
                        p.amenities['wifi'] == true,
                      ),
                      _amenityTile(
                        'Water',
                        Icons.water_drop_outlined,
                        p.amenities['water'] == true,
                      ),
                      _amenityTile(
                        'Electricity',
                        Icons.bolt_outlined,
                        p.amenities['electricity'] == true,
                      ),
                      _amenityTile(
                        'Security',
                        Icons.security_outlined,
                        p.amenities['security'] == true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Rooms
                  if (p.rooms.isNotEmpty) ...[
                    const Text(
                      'Room Types',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...p.rooms.map((room) => _roomRow(room)),
                    const SizedBox(height: 20),
                  ],

                  // Landlord info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.landlordName ?? 'Landlord',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                p.landlordPhone ?? '',
                                style: const TextStyle(
                                  color: AppTheme.gray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: ElevatedButton.icon(
          onPressed: _callLandlord,
          icon: const Icon(Icons.phone_outlined),
          label: Text('Call ${p.landlordName ?? 'Landlord'}'),
        ),
      ),
    );
  }

  Widget _amenityTile(String label, IconData icon, bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: available ? AppTheme.primaryLight : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              available
                  ? AppTheme.primary.withOpacity(0.3)
                  : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: available ? AppTheme.primary : AppTheme.gray,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: available ? AppTheme.primary : AppTheme.gray,
              fontWeight: available ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomRow(Room room) {
    final isFull = room.availableRooms == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isFull ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isFull
                  ? AppTheme.error.withOpacity(0.3)
                  : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      room.roomType[0].toUpperCase() +
                          room.roomType.substring(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isFull
                                ? AppTheme.error.withOpacity(0.1)
                                : AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isFull ? 'Full' : '${room.availableRooms} available',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isFull ? AppTheme.error : AppTheme.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${room.studentsPerRoom} student${room.studentsPerRoom > 1 ? 's' : ''} per room',
                  style: const TextStyle(fontSize: 12, color: AppTheme.gray),
                ),
              ],
            ),
          ),
          Text(
            'K${room.pricePerMonth.toStringAsFixed(0)}/mo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isFull ? AppTheme.gray : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── PHOTO GALLERY SCREEN ──────────────────────────────────────

class _PhotoGalleryScreen extends StatelessWidget {
  final List<dynamic> photos;
  final String title;

  const _PhotoGalleryScreen({required this.photos, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: photos.length,
        itemBuilder:
            (_, i) => GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              _FullScreenPhoto(photos: photos, initialIndex: i),
                    ),
                  ),
              child: CachedNetworkImage(
                imageUrl: photos[i].url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[900]),
                errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
              ),
            ),
      ),
    );
  }
}

// ── FULL SCREEN PHOTO ─────────────────────────────────────────

class _FullScreenPhoto extends StatefulWidget {
  final List<dynamic> photos;
  final int initialIndex;

  const _FullScreenPhoto({required this.photos, required this.initialIndex});

  @override
  State<_FullScreenPhoto> createState() => _FullScreenPhotoState();
}

class _FullScreenPhotoState extends State<_FullScreenPhoto> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder:
            (_, i) => InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.photos[i].url,
                  fit: BoxFit.contain,
                  placeholder:
                      (_, __) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                  errorWidget:
                      (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 48,
                      ),
                ),
              ),
            ),
      ),
    );
  }
}
