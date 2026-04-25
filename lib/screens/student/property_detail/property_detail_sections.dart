import 'package:flutter/material.dart';

import '../../../models/property.dart';
import '../../../utils/student_nest_icons.dart';
import '../../../utils/theme.dart';
import 'property_amenity_tile.dart';
import 'property_room_row.dart';

class PropertyAmenitiesSection extends StatelessWidget {
  const PropertyAmenitiesSection({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PropertyAmenityTile(
              label: 'WiFi',
              assetIcon: StudentNestIcons.wifi,
              available: property.amenities['wifi'] == true,
            ),
            PropertyAmenityTile(
              label: 'Water',
              assetIcon: StudentNestIcons.utilities,
              available: property.amenities['water'] == true,
            ),
            PropertyAmenityTile(
              label: 'Electricity',
              assetIcon: StudentNestIcons.utilities,
              available: property.amenities['electricity'] == true,
            ),
            PropertyAmenityTile(
              label: 'Security',
              assetIcon: StudentNestIcons.safety,
              available: property.amenities['security'] == true,
            ),
          ],
        ),
      ],
    );
  }
}

class PropertyRoomsSection extends StatelessWidget {
  const PropertyRoomsSection({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    if (property.rooms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Types',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 10),
        ...property.rooms.map((room) => PropertyRoomRow(room: room)),
      ],
    );
  }
}
