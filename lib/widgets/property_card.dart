import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/property.dart';
import '../utils/theme.dart';

class PropertyCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.landlordName ?? 'Owner',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.dark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Owner',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.gray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (property.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 170,
                      width: double.infinity,
                      child:
                          coverPhoto != null
                              ? CachedNetworkImage(
                                imageUrl: coverPhoto.url,
                                fit: BoxFit.cover,
                                memCacheHeight: 340,
                                maxHeightDiskCache: 680,
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
                                errorWidget:
                                    (_, __, ___) =>
                                        const _PropertyImagePlaceholder(),
                              )
                              : const _PropertyImagePlaceholder(),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.12),
                              Colors.black.withValues(alpha: 0.42),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.34),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.38),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFE34D),
                              size: 15,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '4',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.bookmark_add_outlined,
                          color: AppTheme.gray,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: const TextStyle(
                        fontSize: 19,
                        color: AppTheme.dark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      property.minPrice != null
                          ? 'K${property.minPrice!.toStringAsFixed(0)}/month'
                          : 'Price on request',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.gray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (distanceKm != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.dark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
      height: 170,
      color: AppTheme.primaryLight,
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 46,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
