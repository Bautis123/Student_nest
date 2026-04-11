import 'package:flutter/material.dart';
import '../../../models/property.dart';
import '../../../utils/theme.dart';
import '../../../widgets/app_status_badge.dart';
import '../../../widgets/app_surface_card.dart';

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
    final isApproved = property.isApproved;

    return GestureDetector(
      onTap: onTap,
      child: AppSurfaceCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        radius: 14,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.home_work_outlined,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.address,
                    style: const TextStyle(fontSize: 12, color: AppTheme.gray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 12,
                        color: AppTheme.gray,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${property.viewCount} views',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.gray,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.phone_outlined,
                        size: 12,
                        color: AppTheme.gray,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${property.contactClickCount} clicks',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.gray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppStatusBadge(
              label: isApproved ? 'Active' : 'Pending',
              color: isApproved ? AppTheme.success : AppTheme.warning,
            ),
          ],
        ),
      ),
    );
  }
}

