import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../utils/student_nest_icons.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'sn_button.dart';
import 'sn_card.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.isSaved = false,
    this.onSavedChanged,
    this.displayDistanceKm,
    this.preferWalkingDistance = false,
  });

  final Property property;
  final VoidCallback onTap;
  final bool isSaved;
  final ValueChanged<bool>? onSavedChanged;
  final double? displayDistanceKm;
  final bool preferWalkingDistance;

  @override
  Widget build(BuildContext context) {
    final coverPhoto = _coverPhoto;
    final distanceKm =
        preferWalkingDistance
            ? displayDistanceKm
            : (displayDistanceKm ?? property.straightLineDistanceKm);

    return RepaintBoundary(
      child: SNCard(
        margin: const EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.zero,
        radius: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PropertyImageHeader(
              coverPhoto: coverPhoto,
              photoCount: property.photos.length,
              isSaved: isSaved,
              onSavedChanged: onSavedChanged,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
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
                      SNButton(
                        label: 'Details',
                        onPressed: onTap,
                        variant: SNButtonVariant.outlined,
                        fullWidth: false,
                        height: 34,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _LandlordFooter(
                    name: property.landlordName ?? AppStrings.owner,
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

  Photo? get _coverPhoto {
    if (property.photos.isEmpty) return null;
    return property.photos.firstWhere(
      (photo) => photo.isCover,
      orElse: () => property.photos.first,
    );
  }
}

class _PropertyImageHeader extends StatelessWidget {
  const _PropertyImageHeader({
    required this.coverPhoto,
    required this.photoCount,
    required this.isSaved,
    required this.onSavedChanged,
  });

  final Photo? coverPhoto;
  final int photoCount;
  final bool isSaved;
  final ValueChanged<bool>? onSavedChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      child: Stack(
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child:
                coverPhoto != null
                    ? CachedNetworkImage(
                      imageUrl: coverPhoto!.url,
                      fit: BoxFit.cover,
                      memCacheWidth: 1200,
                      memCacheHeight: 900,
                      maxWidthDiskCache: 1600,
                      maxHeightDiskCache: 1200,
                      fadeInDuration: const Duration(milliseconds: 100),
                      placeholder: (_, __) => const _PropertyImagePlaceholder(),
                      errorWidget:
                          (_, __, ___) => const _PropertyImagePlaceholder(),
                    )
                    : const _PropertyImagePlaceholder(),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: _SaveButton(
              isSaved: isSaved,
              onTap: () => onSavedChanged?.call(!isSaved),
            ),
          ),
          if (photoCount > 0)
            Positioned(
              right: 12,
              bottom: 12,
              child: _ImageBadge(
                icon: Icons.image_outlined,
                label: '$photoCount photos',
              ),
            ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaved, required this.onTap});

  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: StudentNestIcon(
              StudentNestIcons.save,
              color: isSaved ? AppColors.primary : AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _PropertyPrice extends StatelessWidget {
  const _PropertyPrice({required this.property, required this.distanceKm});

  final Property property;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final price = property.minPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    price != null
                        ? Formatters.currency(price)
                        : AppStrings.price,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text:
                    price != null ? AppStrings.perMonth : AppStrings.onRequest,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
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
              const StudentNestIcon(
                StudentNestIcons.mapPin,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  Formatters.distance(distanceKm!),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const StudentNestIcon(
            StudentNestIcons.profile,
            color: AppColors.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        if (isVerified) ...[
          const SizedBox(width: 5),
          const StudentNestIcon(
            StudentNestIcons.verified,
            color: AppColors.primary,
            size: 13,
          ),
        ],
      ],
    );
  }
}

class _ImageBadge extends StatelessWidget {
  const _ImageBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyImagePlaceholder extends StatelessWidget {
  const _PropertyImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.primaryTint,
      child: Center(
        child: StudentNestIcon(
          StudentNestIcons.building,
          size: 34,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
