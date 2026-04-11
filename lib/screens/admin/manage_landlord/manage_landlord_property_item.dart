import 'package:flutter/material.dart';

import '../../../utils/theme.dart';
import '../../../widgets/app_status_badge.dart';
import '../../../widgets/app_surface_card.dart';

class ManageLandlordPropertyItem extends StatelessWidget {
  final Map<String, dynamic> property;

  const ManageLandlordPropertyItem({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = property['is_approved'] == true;
    final theme = Theme.of(context);

    return AppSurfaceCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      radius: 12,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.home_work_outlined,
              color: AppTheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['title'] ?? '',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  property['address'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppTheme.gray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ManageLandlordPropertyStatusChip(isApproved: isApproved),
        ],
      ),
    );
  }
}

class ManageLandlordPropertyStatusChip extends StatelessWidget {
  final bool isApproved;

  const ManageLandlordPropertyStatusChip({
    super.key,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(
      label: isApproved ? 'Live' : 'Pending',
      color: isApproved ? AppTheme.success : AppTheme.warning,
      fontSize: 10,
      horizontalPadding: 7,
      verticalPadding: 3,
      radius: 10,
      fontWeight: FontWeight.w500,
    );
  }
}
