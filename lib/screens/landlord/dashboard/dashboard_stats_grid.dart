import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';
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
      childAspectRatio: 1.3,
      children: [
        DashboardStatCard(
          label: 'Total Views',
          value: totalViews.toString(),
          icon: Icons.visibility_outlined,
          color: AppDesign.accent,
        ),
        DashboardStatCard(
          label: 'Contact Clicks',
          value: totalClicks.toString(),
          icon: Icons.phone_outlined,
          color: AppDesign.accent,
        ),
        DashboardStatCard(
          label: 'Active Listings',
          value: activeListings.toString(),
          icon: Icons.check_circle_outline,
          color: AppDesign.accent,
        ),
        DashboardStatCard(
          label: 'Pending',
          value: pendingListings.toString(),
          icon: Icons.hourglass_empty_outlined,
          color: AppColors.warning,
        ),
      ],
    );
  }
}
