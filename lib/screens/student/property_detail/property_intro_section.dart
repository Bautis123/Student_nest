import 'package:flutter/material.dart';
import '../../../models/property.dart';
import '../../../utils/student_nest_icons.dart';
import '../../../utils/theme.dart';

class PropertyIntroSection extends StatelessWidget {
  final Property property;
  final double? walkingDistanceKm;

  const PropertyIntroSection({
    super.key,
    required this.property,
    this.walkingDistanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final distanceKm = walkingDistanceKm ?? property.straightLineDistanceKm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                property.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.dark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Available',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (distanceKm != null) _distanceBadge(distanceKm),
        if (distanceKm != null) const SizedBox(height: 16),
        Row(
          children: [
            const StudentNestIcon(
              StudentNestIcons.mapPin,
              size: 17,
              color: Color(0xFFA0A8B8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                property.address,
                style: const TextStyle(
                  color: Color(0xFF8A94A6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (property.description != null &&
            property.description!.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text(
            'About',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            property.description!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF697386),
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _distanceBadge(double distanceKm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const StudentNestIcon(
            StudentNestIcons.university,
            size: 16,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              walkingDistanceKm != null
                  ? '${distanceKm.toStringAsFixed(2)} km walk to ${property.schoolName ?? 'UNZA'}'
                  : '${distanceKm.toStringAsFixed(2)} km from ${property.schoolName ?? 'UNZA'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
