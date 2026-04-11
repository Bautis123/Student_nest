import 'package:flutter/material.dart';

import '../../../utils/theme.dart';
import '../../../widgets/app_status_badge.dart';
import '../../../widgets/app_surface_card.dart';

class ManageLandlordStatusCard extends StatelessWidget {
  final bool isApproved;
  final int propertyCount;

  const ManageLandlordStatusCard({
    super.key,
    required this.isApproved,
    required this.propertyCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = isApproved ? AppTheme.success : AppTheme.warning;
    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          AppStatusBadge(
            label: isApproved ? 'Active account' : 'Pending approval',
            color: statusColor,
            fontSize: 12,
            horizontalPadding: 10,
            verticalPadding: 5,
          ),
          const Spacer(),
          Text(
            '$propertyCount listing${propertyCount == 1 ? '' : 's'}',
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
