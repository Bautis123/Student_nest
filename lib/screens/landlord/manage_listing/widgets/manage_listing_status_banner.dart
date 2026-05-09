import 'package:flutter/material.dart';

import '../../../../models/property.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/app_status_badge.dart';
import 'package:student_nest/core/widgets/app_surface_card.dart';

class ManageListingStatusBanner extends StatelessWidget {
  final Property property;

  const ManageListingStatusBanner({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        property.isApproved ? AppDesign.accent : AppColors.warning;
    final statusText =
        property.isApproved
            ? 'Live - visible to students'
            : 'Pending admin approval';
    final theme = Theme.of(context);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      color:
          property.isApproved
              ? AppColors.primaryTint
              : AppColors.warning.withValues(alpha: 0.08),
      borderColor:
          property.isApproved
              ? AppDesign.accent.withValues(alpha: 0.16)
              : AppColors.warning.withValues(alpha: 0.16),
      child: Row(
        children: [
          AppStatusBadge(
            label: statusText,
            color: statusColor,
            fontSize: 12,
            horizontalPadding: 10,
            verticalPadding: 5,
          ),
          const Spacer(),
          Text(
            '${property.viewCount} views',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: AppDesign.muted(context),
            ),
          ),
        ],
      ),
    );
  }
}
