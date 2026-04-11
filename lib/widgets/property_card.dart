import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/property.dart';
import '../utils/theme.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final coverPhoto =
        property.photos.isNotEmpty
            ? property.photos.firstWhere(
              (p) => p.isCover,
              orElse: () => property.photos.first,
            )
            : null;
    final amenityChips = <Widget>[
      if (property.amenities['wifi'] == true)
        const _AmenityChip(label: 'WiFi', icon: Icons.wifi),
      if (property.amenities['water'] == true)
        const _AmenityChip(label: 'Water', icon: Icons.water_drop_outlined),
      if (property.amenities['electricity'] == true)
        const _AmenityChip(label: 'Electric', icon: Icons.bolt_outlined),
      if (property.amenities['security'] == true)
        const _AmenityChip(label: 'Security', icon: Icons.security_outlined),
    ];

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child:
                      coverPhoto != null
                          ? CachedNetworkImage(
                            imageUrl: coverPhoto.url,
                            fit: BoxFit.cover,
                            memCacheHeight: 360,
                            maxHeightDiskCache: 720,
                            fadeInDuration: const Duration(milliseconds: 100),
                            placeholder:
                                (_, __) => Container(
                                  color: AppTheme.primaryLight,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget: (_, __, ___) =>
                                const _PropertyImagePlaceholder(),
                          )
                          : const _PropertyImagePlaceholder(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + available badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.dark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
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
                    const SizedBox(height: 6),

                    // Location + distance
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppTheme.gray,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            property.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.gray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (property.distanceFromSchool != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 14,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${property.distanceFromSchool!.toStringAsFixed(2)} km from ${property.schoolName ?? 'UNZA'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Amenities
                    Wrap(spacing: 6, runSpacing: 4, children: amenityChips),
                    const SizedBox(height: 10),

                    // Price + contact
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.minPrice != null
                                  ? 'From K${property.minPrice!.toStringAsFixed(0)}/mo'
                                  : 'Price on request',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            if (property.rooms.isNotEmpty)
                              Text(
                                '${property.rooms.length} room type${property.rooms.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.gray,
                                ),
                              ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(100, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyImagePlaceholder extends StatelessWidget {
  const _PropertyImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: AppTheme.primaryLight,
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 48,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppTheme.primary),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}
