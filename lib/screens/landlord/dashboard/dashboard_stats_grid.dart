import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import 'dashboard_stat_card.dart';

class DashboardStatsGrid extends StatelessWidget {
  final int totalViews;
  final int totalClicks;
  final int activeListings;
  final int pendingListings;

  const DashboardStatsGrid({
    super.key,
    required this.totalViews,
    required this.totalClicks,
    required this.activeListings,
    required this.pendingListings,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        DashboardStatCard(
          label: 'Total Views',
          value: totalViews.toString(),
          icon: Icons.visibility_outlined,
          color: AppTheme.primary,
        ),
        DashboardStatCard(
          label: 'Contact Clicks',
          value: totalClicks.toString(),
          icon: Icons.phone_outlined,
          color: AppTheme.success,
        ),
        DashboardStatCard(
          label: 'Active Listings',
          value: activeListings.toString(),
          icon: Icons.check_circle_outline,
          color: const Color(0xFF8B5CF6),
        ),
        DashboardStatCard(
          label: 'Pending',
          value: pendingListings.toString(),
          icon: Icons.hourglass_empty_outlined,
          color: AppTheme.warning,
        ),
      ],
    );
  }
}
