import 'package:flutter/material.dart';
import '../../../models/property.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/app_surface_card.dart';
import 'package:student_nest/features/landlord/widgets/occupancy_summary_card.dart';
import 'dashboard_listings_section.dart';
import 'dashboard_stats_grid.dart';

class DashboardBody extends StatelessWidget {
  final List<Property> properties;
  final int totalViews;
  final int totalClicks;
  final int activeListings;
  final int pendingListings;
  final ValueChanged<Property> onOpenListing;
  final bool listingsOnly;
  final VoidCallback? onAddListing;

  const DashboardBody({
    super.key,
    required this.properties,
    required this.totalViews,
    required this.totalClicks,
    required this.activeListings,
    required this.pendingListings,
    required this.onOpenListing,
    this.listingsOnly = false,
    this.onAddListing,
  });

  @override
  Widget build(BuildContext context) {
    final roomSummary = _RoomSummary.fromProperties(properties);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, listingsOnly ? 14 : 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!listingsOnly) ...[
            DashboardStatsGrid(
              totalViews: totalViews,
              totalClicks: totalClicks,
              activeListings: activeListings,
              pendingListings: pendingListings,
            ),
            const SizedBox(height: 14),
            OccupancySummaryCard(
              total: roomSummary.total,
              occupied: roomSummary.occupied,
              vacant: roomSummary.vacant,
            ),
            const SizedBox(height: 14),
            _AddListingActionCard(onTap: onAddListing),
          ] else
            DashboardListingsSection(
              properties: properties,
              onOpenListing: onOpenListing,
            ),
          if (listingsOnly) const SizedBox(height: 132),
        ],
      ),
    );
  }
}

class _AddListingActionCard extends StatelessWidget {
  const _AddListingActionCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AppSurfaceCard(
          radius: 22,
          padding: const EdgeInsets.all(16),
          color: AppDesign.accentTint(context),
          borderColor: AppDesign.accent.withValues(alpha: 0.14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppDesign.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.add_home_work_outlined,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add listing',
                      style: TextStyle(
                        color: AppDesign.text(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Create a new boarding house listing',
                      style: TextStyle(
                        color: AppDesign.muted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppDesign.accent,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomSummary {
  const _RoomSummary({
    required this.total,
    required this.occupied,
    required this.vacant,
  });

  final int total;
  final int occupied;
  final int vacant;

  factory _RoomSummary.fromProperties(List<Property> properties) {
    var total = 0;
    var occupied = 0;
    var vacant = 0;

    for (final property in properties) {
      if (property.totalRoomsCount != null ||
          property.availableRoomsCount != null ||
          property.occupiedRoomsCount != null) {
        total += property.totalRoomsCount ?? 0;
        occupied += property.occupiedRoomsCount ?? 0;
        vacant += property.availableRoomsCount ?? 0;
      } else {
        for (final room in property.rooms) {
          total += room.totalRooms;
          vacant += room.availableRooms;
        }
      }
    }

    return _RoomSummary(
      total: total,
      occupied:
          occupied > 0
              ? occupied.clamp(0, total).toInt()
              : (total - vacant).clamp(0, total).toInt(),
      vacant: vacant.clamp(0, total).toInt(),
    );
  }
}
