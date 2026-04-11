import 'package:flutter/material.dart';

import '../../../utils/theme.dart';
import '../../../widgets/app_status_badge.dart';
import '../../../widgets/app_surface_card.dart';

class AdminPropertyListItem extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const AdminPropertyListItem({
    super.key,
    required this.property,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = property['is_approved'] == false;
    final theme = Theme.of(context);
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;

    return AppSurfaceCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'] ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      property['landlord_name'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                    Text(
                      property['address'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppStatusBadge(
                label: isPending ? 'Pending' : 'Live',
                color: isPending ? AppTheme.warning : AppTheme.success,
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: BorderSide(
                        color: AppTheme.error.withValues(alpha: 0.5),
                      ),
                      minimumSize: const Size(double.infinity, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      minimumSize: const Size(double.infinity, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
