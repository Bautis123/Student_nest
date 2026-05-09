import 'package:flutter/material.dart';
import '../../../models/property.dart';
import 'package:student_nest/core/constants/app_strings.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/utils/formatters.dart';
import '../../../utils/student_nest_icons.dart';

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
                style: TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppDesign.text(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Available',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (distanceKm != null) _distanceBadge(context, distanceKm),
        if (distanceKm != null) const SizedBox(height: 16),
        Row(
          children: [
            const StudentNestIcon(
              StudentNestIcons.mapPin,
              size: 17,
              color: AppColors.textHint,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                property.address,
                style: const TextStyle(
                  color: AppColors.textHint,
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
          Text(
            'About',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppDesign.text(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            property.description!,
            style: TextStyle(
              fontSize: 13,
              color: AppDesign.muted(context),
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _distanceBadge(BuildContext context, double distanceKm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppDesign.accentTint(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const StudentNestIcon(
            StudentNestIcons.university,
            size: 16,
            color: AppDesign.accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              Formatters.schoolDistance(
                distanceKm: distanceKm,
                schoolName: property.schoolName ?? AppStrings.unza,
                isWalking: walkingDistanceKm != null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppDesign.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
