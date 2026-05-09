import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../models/property.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/app_status_badge.dart';
import 'package:student_nest/core/widgets/app_surface_card.dart';

class DashboardListingCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const DashboardListingCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _listingStatus(property);
    final address = _sentenceCase(property.address);
    final coverPhoto =
        property.photos.isNotEmpty
            ? property.photos.firstWhere(
              (p) => p.isCover,
              orElse: () => property.photos.first,
            )
            : null;

    return GestureDetector(
      onTap: onTap,
      child: AppSurfaceCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        radius: 22,
        showShadow: true,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 52,
                height: 52,
                child:
                    coverPhoto != null
                        ? CachedNetworkImage(
                          imageUrl: coverPhoto.url,
                          fit: BoxFit.cover,
                          placeholder:
                              (_, __) => const _ListingThumbnailPlaceholder(),
                          errorWidget:
                              (_, __, ___) =>
                                  const _ListingThumbnailPlaceholder(),
                        )
                        : const _ListingThumbnailPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppDesign.text(context),
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppStatusBadge(label: status.label, color: status.color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppDesign.muted(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MetricText(
                        icon: Icons.visibility_outlined,
                        value: property.viewCount,
                        label: 'views',
                      ),
                      const SizedBox(width: 10),
                      _MetricText(
                        icon: Icons.phone_outlined,
                        value: property.contactClickCount,
                        label: 'clicks',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sentenceCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  _ListingStatus _listingStatus(Property property) {
    final expiresAt = property.listingExpiresAt;
    final parsed = expiresAt == null ? null : DateTime.tryParse(expiresAt);
    final isExpired =
        !property.isActive ||
        (parsed != null && parsed.isBefore(DateTime.now()));

    if (!property.isApproved) {
      return const _ListingStatus('Pending', AppColors.warning);
    }
    if (isExpired) {
      return const _ListingStatus('Expired', AppColors.textSecondary);
    }
    return const _ListingStatus('Active', AppDesign.accent);
  }
}

class _MetricText extends StatelessWidget {
  const _MetricText({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color =
        value == 0
            ? AppDesign.muted(context).withValues(alpha: 0.55)
            : AppDesign.muted(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text('$value $label', style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

class _ListingStatus {
  const _ListingStatus(this.label, this.color);

  final String label;
  final Color color;
}

class _ListingThumbnailPlaceholder extends StatelessWidget {
  const _ListingThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppDesign.accentTint(context),
      child: const Icon(
        Icons.home_work_outlined,
        color: AppDesign.accent,
        size: 29,
      ),
    );
  }
}
