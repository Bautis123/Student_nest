import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/property.dart';
import '../utils/app_design.dart';
import '../utils/student_nest_icons.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback onTap;
  final bool isSaved;
  final ValueChanged<bool>? onSavedChanged;
  final double? displayDistanceKm;
  final bool preferWalkingDistance;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.isSaved = false,
    this.onSavedChanged,
    this.displayDistanceKm,
    this.preferWalkingDistance = false,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  void _toggleSaved() {
    widget.onSavedChanged?.call(!widget.isSaved);
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final coverPhoto =
        property.photos.isNotEmpty
            ? property.photos.firstWhere(
              (p) => p.isCover,
              orElse: () => property.photos.first,
            )
            : null;
    final distanceKm =
        widget.preferWalkingDistance
            ? widget.displayDistanceKm
            : (widget.displayDistanceKm ?? property.straightLineDistanceKm);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: AppDesign.surfaceDecoration(context, radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child:
                        coverPhoto != null
                            ? CachedNetworkImage(
                              imageUrl: coverPhoto.url,
                              fit: BoxFit.cover,
                              memCacheWidth: 1200,
                              memCacheHeight: 900,
                              maxWidthDiskCache: 1600,
                              maxHeightDiskCache: 1200,
                              fadeInDuration: const Duration(
                                milliseconds: 100,
                              ),
                              placeholder:
                                  (_, __) => const _PropertyImagePlaceholder(),
                              errorWidget:
                                  (_, __, ___) =>
                                      const _PropertyImagePlaceholder(),
                            )
                            : const _PropertyImagePlaceholder(),
                  ),
                  const Positioned(
                    left: 12,
                    top: 12,
                    child: _ImageBadge(
                      icon: Icons.star_rounded,
                      iconColor: Color(0xFFFFD426),
                      label: '4.0',
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: _SaveButton(
                      isSaved: widget.isSaved,
                      onSaveTap: _toggleSaved,
                    ),
                  ),
                  if (property.photos.isNotEmpty)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: _ImageBadge(
                        icon: Icons.image_outlined,
                        iconColor: Colors.white,
                        label: '${property.photos.length} photos',
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppDesign.text(context),
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _PropertyPrice(
                          property: property,
                          distanceKm: distanceKm,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _ViewDetailsButton(onTap: widget.onTap),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _LandlordFooter(
                    name: property.landlordName ?? 'Owner',
                    isVerified: property.isApproved,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaved, required this.onSaveTap});

  final bool isSaved;
  final VoidCallback onSaveTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSaveTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: StudentNestIcon(
              StudentNestIcons.save,
              color:
                  isSaved ? AppDesign.accent : AppDesign.text(context),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _LandlordFooter extends StatelessWidget {
  const _LandlordFooter({required this.name, required this.isVerified});

  final String name;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppDesign.accentTint(context),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const StudentNestIcon(
            StudentNestIcons.profile,
            color: AppDesign.accent,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppDesign.muted(context),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        if (isVerified) ...[
          const SizedBox(width: 5),
          const StudentNestIcon(
            StudentNestIcons.verified,
            color: AppDesign.accent,
            size: 13,
          ),
        ],
      ],
    );
  }
}

class _PropertyPrice extends StatelessWidget {
  const _PropertyPrice({required this.property, required this.distanceKm});

  final Property property;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    property.minPrice != null
                        ? 'K${property.minPrice!.toStringAsFixed(0)}'
                        : 'Price',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppDesign.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: property.minPrice != null ? ' /month' : ' on request',
                style: TextStyle(
                  fontSize: 13,
                  color: AppDesign.text(context),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (distanceKm != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              StudentNestIcon(
                StudentNestIcons.mapPin,
                size: 15,
                color: AppDesign.muted(context),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${distanceKm!.toStringAsFixed(1)} km away',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppDesign.muted(context),
                    fontWeight: FontWeight.w400,
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

class _ViewDetailsButton extends StatelessWidget {
  const _ViewDetailsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppDesign.accent),
          ),
          child: const Center(
            child: Text(
              'Details',
              style: TextStyle(
                color: AppDesign.accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
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
      width: double.infinity,
      color: AppDesign.accentTint(context),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StudentNestIcon(
              StudentNestIcons.building,
              size: 34,
              color: AppDesign.accent,
            ),
            const SizedBox(height: 8),
            Text(
              'No photos yet',
              style: TextStyle(
                color: AppDesign.muted(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
