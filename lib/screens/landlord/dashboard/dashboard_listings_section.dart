import 'package:flutter/material.dart';
import '../../../models/property.dart';
import '../../../utils/theme.dart';
import 'dashboard_listing_card.dart';
import 'empty_listings_card.dart';

class DashboardListingsSection extends StatelessWidget {
  final List<Property> properties;
  final VoidCallback onAddNew;
  final ValueChanged<Property> onOpenListing;

  const DashboardListingsSection({
    super.key,
    required this.properties,
    required this.onAddNew,
    required this.onOpenListing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Listings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.dark,
              ),
            ),
            TextButton.icon(
              onPressed: onAddNew,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add New'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (properties.isEmpty)
          const EmptyListingsCard()
        else
          Column(
            children:
                properties
                    .map(
                      (property) => DashboardListingCard(
                        property: property,
                        onTap: () => onOpenListing(property),
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }
}
