import 'package:flutter/material.dart';

import '../../../../models/property.dart';
import '../../../../utils/theme.dart';
import '../../../../widgets/app_status_badge.dart';
import '../../../../widgets/app_surface_card.dart';

class ManageListingStatusBanner extends StatelessWidget {
  final Property property;

  const ManageListingStatusBanner({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final statusColor = property.isApproved ? AppTheme.success : AppTheme.warning;
    final statusText =
        property.isApproved ? 'Live - visible to students' : 'Pending admin approval';
    final theme = Theme.of(context);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
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
              color: AppTheme.gray,
            ),
          ),
        ],
      ),
    );
  }
}
