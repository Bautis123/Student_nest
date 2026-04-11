import 'package:flutter/material.dart';
import '../../../models/property.dart';
import 'dashboard_listings_section.dart';
import 'dashboard_stats_grid.dart';

class DashboardBody extends StatelessWidget {
  final List<Property> properties;
  final int totalViews;
  final int totalClicks;
  final int activeListings;
  final int pendingListings;
  final VoidCallback onAddNew;
  final ValueChanged<Property> onOpenListing;

  const DashboardBody({
    super.key,
    required this.properties,
    required this.totalViews,
    required this.totalClicks,
    required this.activeListings,
    required this.pendingListings,
    required this.onAddNew,
    required this.onOpenListing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardStatsGrid(
            totalViews: totalViews,
            totalClicks: totalClicks,
            activeListings: activeListings,
            pendingListings: pendingListings,
          ),
          const SizedBox(height: 24),
          DashboardListingsSection(
            properties: properties,
            onAddNew: onAddNew,
            onOpenListing: onOpenListing,
          ),
        ],
      ),
    );
  }
}
