import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/property.dart';
import '../utils/student_nest_icons.dart';
import '../utils/theme.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback onTap;
  final double? displayDistanceKm;
  final bool preferWalkingDistance;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.displayDistanceKm,
    this.preferWalkingDistance = false,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _isSaved = false;

  void _toggleSaved() {
    setState(() => _isSaved = !_isSaved);
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final onTap = widget.onTap;
    final displayDistanceKm = widget.displayDistanceKm;
    final preferWalkingDistance = widget.preferWalkingDistance;

    final coverPhoto =
        property.photos.isNotEmpty
            ? property.photos.firstWhere(
              (p) => p.isCover,
              orElse: () => property.photos.first,
            )
            : null;
    final distanceKm =
        preferWalkingDistance
            ? displayDistanceKm
            : (displayDistanceKm ?? property.straightLineDistanceKm);

    return RepaintBoundary(
      child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667085).withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LandlordHeader(
                name: property.landlordName ?? 'Owner',
                isSaved: _isSaved,
                onSaveTap: _toggleSaved,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child:
                          coverPhoto != null
                              ? CachedNetworkImage(
                                imageUrl: coverPhoto.url,
                                fit: BoxFit.cover,
                        memCacheHeight: 272,
                        maxHeightDiskCache: 544,
                                fadeInDuration: const Duration(
                                  milliseconds: 100,
                                ),
                                placeholder:
                                    (_, __) => Container(
                                      color: AppTheme.primaryLight,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (_, __, ___) =>
                                        const _PropertyImagePlaceholder(),
                              )
                              : const _PropertyImagePlaceholder(),
                    ),
                    const Positioned(
                      left: 10,
                      top: 10,
                      child: _ImageBadge(
                        icon: Icons.star_rounded,
                        iconColor: Color(0xFFFFD426),
                        label: '4.0',
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _ImageBadge(
                        icon: Icons.image_outlined,
                        iconColor: Colors.white,
                        label:
                            '${property.photos.isEmpty ? 0 : property.photos.length} photos',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 4, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _PropertySummary(
                        property: property,
                        distanceKm: distanceKm,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ViewDetailsButton(onTap: onTap),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
}

class _LandlordHeader extends StatelessWidget {
  const _LandlordHeader({
    required this.name,
    required this.isSaved,
    required this.onSaveTap,
  });

  final String name;
  final bool isSaved;
  final VoidCallback onSaveTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const StudentNestIcon(
              StudentNestIcons.profile,
              color: AppTheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const StudentNestIcon(
                      StudentNestIcons.verified,
                      color: AppTheme.primary,
                      size: 15,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Owner',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onSaveTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE6EAF2)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64748B).withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: StudentNestIcon(
                  StudentNestIcons.save,
                  color: isSaved ? AppTheme.primary : const Color(0xFF111827),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  const _ImageBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertySummary extends StatelessWidget {
  const _PropertySummary({required this.property, required this.distanceKm});

  final Property property;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    property.minPrice != null
                        ? 'K${property.minPrice!.toStringAsFixed(0)}'
                        : 'Price',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: property.minPrice != null ? ' /month' : ' on request',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (distanceKm != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const StudentNestIcon(
                StudentNestIcons.mapPin,
                size: 15,
                color: Color(0xFF4B5563),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${distanceKm!.toStringAsFixed(1)} km away',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF98A2B3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ViewDetailsButton extends StatelessWidget {
  const _ViewDetailsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryLight,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: const SizedBox(
          height: 40,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, color: AppTheme.primary, size: 16),
              ],
            ),
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
      height: 150,
      color: AppTheme.primaryLight,
      child: const Center(
        child: StudentNestIcon(
          StudentNestIcons.building,
          size: 36,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
