import 'package:flutter/material.dart';
import '../../../models/property.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'dashboard_listing_card.dart';
import 'empty_listings_card.dart';

enum DashboardListingFilter { all, active, pending, expired }

class DashboardListingsSection extends StatefulWidget {
  final List<Property> properties;
  final ValueChanged<Property> onOpenListing;

  const DashboardListingsSection({
    super.key,
    required this.properties,
    required this.onOpenListing,
  });

  @override
  State<DashboardListingsSection> createState() =>
      _DashboardListingsSectionState();
}

class _DashboardListingsSectionState extends State<DashboardListingsSection> {
  DashboardListingFilter _filter = DashboardListingFilter.all;

  bool _isExpired(Property property) {
    if (!property.isActive) return true;
    final expiresAt = property.listingExpiresAt;
    if (expiresAt == null) return false;
    final parsed = DateTime.tryParse(expiresAt);
    return parsed != null && parsed.isBefore(DateTime.now());
  }

  List<Property> get _filteredProperties {
    switch (_filter) {
      case DashboardListingFilter.active:
        return widget.properties
            .where((p) => p.isApproved && p.isActive && !_isExpired(p))
            .toList();
      case DashboardListingFilter.pending:
        return widget.properties.where((p) => !p.isApproved).toList();
      case DashboardListingFilter.expired:
        return widget.properties.where(_isExpired).toList();
      case DashboardListingFilter.all:
        return widget.properties;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProperties = _filteredProperties;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Listings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppDesign.text(context),
              ),
            ),
            Text(
              '${widget.properties.length} total',
              style: TextStyle(
                color: AppDesign.muted(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                DashboardListingFilter.values
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: _filterLabel(filter),
                          selected: _filter == filter,
                          onTap: () => setState(() => _filter = filter),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (filteredProperties.isEmpty)
          const EmptyListingsCard()
        else
          Column(
            children:
                filteredProperties
                    .map(
                      (property) => DashboardListingCard(
                        property: property,
                        onTap: () => widget.onOpenListing(property),
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }

  String _filterLabel(DashboardListingFilter filter) {
    switch (filter) {
      case DashboardListingFilter.active:
        return 'Active';
      case DashboardListingFilter.pending:
        return 'Pending';
      case DashboardListingFilter.expired:
        return 'Expired';
      case DashboardListingFilter.all:
        return 'All';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppDesign.accent : AppDesign.surface(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppDesign.accent : AppDesign.border(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppDesign.muted(context),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
