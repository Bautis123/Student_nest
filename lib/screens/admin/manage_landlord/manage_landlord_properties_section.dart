import 'package:flutter/material.dart';

import '../../../utils/theme.dart';
import 'manage_landlord_empty_properties.dart';
import 'manage_landlord_property_item.dart';

class ManageLandlordPropertiesSection extends StatelessWidget {
  final List<dynamic> properties;

  const ManageLandlordPropertiesSection({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Listings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 12),
        if (properties.isEmpty)
          const ManageLandlordEmptyProperties()
        else
          ...properties.map(
            (property) => ManageLandlordPropertyItem(property: property),
          ),
      ],
    );
  }
}
