import 'package:flutter/material.dart';

import '../../../utils/theme.dart';
import '../../../widgets/app_status_badge.dart';
import '../../../widgets/app_surface_card.dart';
import '../manage_landlord_screen.dart';

class AdminLandlordListItem extends StatelessWidget {
  final Map<String, dynamic> landlord;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final Future<void> Function() onRefresh;

  const AdminLandlordListItem({
    super.key,
    required this.landlord,
    required this.onApprove,
    required this.onReject,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = landlord['is_approved'] == false;
    final theme = Theme.of(context);
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManageLandlordScreen(landlord: landlord),
        ),
      ).then((_) => onRefresh()),
      child: AppSurfaceCard(
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
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        landlord['full_name'] ?? '',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        landlord['phone'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                      if (landlord['email'] != null)
                        Text(
                          landlord['email'],
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
                AppStatusBadge(
                  label: isPending ? 'Pending' : 'Active',
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
      ),
    );
  }
}
