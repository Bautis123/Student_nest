import 'package:flutter/material.dart';

import '../../../utils/theme.dart';
import 'admin_revenue_card.dart';
import 'admin_overview_stat_card.dart';

class AdminDashboardOverviewTab extends StatelessWidget {
  final Map<String, dynamic> stats;

  const AdminDashboardOverviewTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              AdminOverviewStatCard(
                label: 'Total Landlords',
                value: '${stats['total_landlords'] ?? 0}',
                icon: Icons.person_outline,
                color: AppTheme.primary,
              ),
              AdminOverviewStatCard(
                label: 'Pending Approval',
                value: '${stats['pending_landlords'] ?? 0}',
                icon: Icons.hourglass_empty_outlined,
                color: AppTheme.warning,
              ),
              AdminOverviewStatCard(
                label: 'Live Listings',
                value: '${stats['total_properties'] ?? 0}',
                icon: Icons.home_work_outlined,
                color: AppTheme.success,
              ),
              AdminOverviewStatCard(
                label: 'Pending Listings',
                value: '${stats['pending_properties'] ?? 0}',
                icon: Icons.pending_outlined,
                color: AppTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          AdminRevenueCard(totalRevenue: stats['total_revenue']),
        ],
      ),
    );
  }
}
