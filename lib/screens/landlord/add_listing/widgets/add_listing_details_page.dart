import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';

import 'listing_amenity_switch_tile.dart';

import 'listing_field_label.dart';

// This widget represents the details page for adding a new listing. It includes fields for title, address, nearest school, description, and amenities.
class AddListingDetailsPage extends StatelessWidget {
  const AddListingDetailsPage({
    super.key,
    required this.titleController,
    required this.addressController,
    required this.descriptionController,
    required this.schools,
    required this.selectedSchoolId,
    required this.hasWifi,
    required this.hasWater,
    required this.hasElectricity,
    required this.hasSecurity,
    required this.onSchoolChanged,
    required this.onWifiChanged,
    required this.onWaterChanged,
    required this.onElectricityChanged,
    required this.onSecurityChanged,
  });

  // Controllers for text fields
  final TextEditingController titleController;
  final TextEditingController addressController;
  final TextEditingController descriptionController;
  final List<Map<String, dynamic>> schools;
  final String? selectedSchoolId;
  final bool hasWifi;
  final bool hasWater;
  final bool hasElectricity;
  final bool hasSecurity;
  final ValueChanged<String?> onSchoolChanged;
  final ValueChanged<bool> onWifiChanged;
  final ValueChanged<bool> onWaterChanged;
  final ValueChanged<bool> onElectricityChanged;
  final ValueChanged<bool> onSecurityChanged;

  // Build method to render the UI
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const ListingFieldLabel('Property Title *'),
          const SizedBox(height: 6),
          TextField(
            controller: titleController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'e.g. Chanda Boarding House',
              prefixIcon: Icon(Icons.home_work_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const ListingFieldLabel('Address *'),
          const SizedBox(height: 6),
          TextField(
            controller: addressController,
            decoration: const InputDecoration(
              hintText: 'e.g. Plot 15, Olympia Park, Lusaka',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const ListingFieldLabel('Nearest School *'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedSchoolId,
            decoration: const InputDecoration(
              hintText: 'Select nearest school',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items:
                schools
                    .map(
                      (school) => DropdownMenuItem<String>(
                        value: school['id'] as String,
                        child: Text(school['name']),
                      ),
                    )
                    .toList(),
            onChanged: onSchoolChanged,
          ),
          const SizedBox(height: 16),
          const ListingFieldLabel('Description'),
          const SizedBox(height: 6),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Describe your property...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          const ListingFieldLabel('Amenities'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                ListingAmenitySwitchTile(
                  label: 'WiFi',
                  icon: Icons.wifi,
                  value: hasWifi,
                  onChanged: onWifiChanged,
                ),
                ListingAmenitySwitchTile(
                  label: 'Water',
                  icon: Icons.water_drop_outlined,
                  value: hasWater,
                  onChanged: onWaterChanged,
                ),
                ListingAmenitySwitchTile(
                  label: 'Electricity',
                  icon: Icons.bolt_outlined,
                  value: hasElectricity,
                  onChanged: onElectricityChanged,
                ),
                ListingAmenitySwitchTile(
                  label: 'Security',
                  icon: Icons.security_outlined,
                  value: hasSecurity,
                  onChanged: onSecurityChanged,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

