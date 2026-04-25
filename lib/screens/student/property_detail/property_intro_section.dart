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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.dark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        const SizedBox(height: 8),
        if (distanceKm != null) _distanceBadge(distanceKm),
        if (distanceKm != null) const SizedBox(height: 8),
        Row(
          children: [
            const StudentNestIcon(
              StudentNestIcons.mapPin,
              size: 16,
              color: AppTheme.gray,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                property.address,
                style: const TextStyle(color: AppTheme.gray, fontSize: 13),
              ),
            ),
          ],
        ),
        if (property.description != null &&
            property.description!.isNotEmpty) ...[
          const SizedBox(height: 20),
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
            property.description!,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.gray,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _distanceBadge(double distanceKm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StudentNestIcon(
            StudentNestIcons.university,
            size: 14,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            walkingDistanceKm != null
                ? '${distanceKm.toStringAsFixed(2)} km walk to ${property.schoolName ?? 'UNZA'}'
                : '${distanceKm.toStringAsFixed(2)} km straight-line from ${property.schoolName ?? 'UNZA'}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
