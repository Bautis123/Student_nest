import 'package:flutter/material.dart';

import '../../../models/property.dart';
import '../../../services/api_service.dart';
import '../../../utils/theme.dart';
import 'widgets/manage_listing_amenity_switch_tile.dart';
import 'widgets/manage_listing_field_label.dart';
import 'widgets/manage_listing_status_banner.dart';

class ManageListingDetailsTab extends StatefulWidget {
  final Property property;
  final VoidCallback onUpdated;

  const ManageListingDetailsTab({
    super.key,
    required this.property,
    required this.onUpdated,
  });

  @override
  State<ManageListingDetailsTab> createState() => _ManageListingDetailsTabState();
}

class _ManageListingDetailsTabState extends State<ManageListingDetailsTab> {
  final ApiService _api = ApiService();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late bool _hasWifi;
  late bool _hasWater;
  late bool _hasElectricity;
  late bool _hasSecurity;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property.title);
    _descriptionController = TextEditingController(
      text: widget.property.description ?? '',
    );
    _addressController = TextEditingController(text: widget.property.address);
    _hasWifi = widget.property.amenities['wifi'] == true;
    _hasWater = widget.property.amenities['water'] == true;
    _hasElectricity = widget.property.amenities['electricity'] == true;
    _hasSecurity = widget.property.amenities['security'] == true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await _api.updateProperty(widget.property.id, {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'amenities': {
          'wifi': _hasWifi,
          'water': _hasWater,
          'electricity': _hasElectricity,
          'security': _hasSecurity,
        },
      });
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });
      widget.onUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _markChanged() => setState(() => _hasChanges = true);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ManageListingStatusBanner(property: widget.property),
          const SizedBox(height: 16),
          const ManageListingFieldLabel('Title'),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            onChanged: (_) => _markChanged(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.home_work_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const ManageListingFieldLabel('Address'),
          const SizedBox(height: 6),
          TextField(
            controller: _addressController,
            onChanged: (_) => _markChanged(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const ManageListingFieldLabel('Description'),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            onChanged: (_) => _markChanged(),
            decoration: const InputDecoration(
              hintText: 'Describe your property...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          const ManageListingFieldLabel('Amenities'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                ManageListingAmenitySwitchTile(
                  label: 'WiFi',
                  icon: Icons.wifi,
                  value: _hasWifi,
                  onChanged: (value) {
                    setState(() {
                      _hasWifi = value;
                      _hasChanges = true;
                    });
                  },
                ),
                ManageListingAmenitySwitchTile(
                  label: 'Water',
                  icon: Icons.water_drop_outlined,
                  value: _hasWater,
                  onChanged: (value) {
                    setState(() {
                      _hasWater = value;
                      _hasChanges = true;
                    });
                  },
                ),
                ManageListingAmenitySwitchTile(
                  label: 'Electricity',
                  icon: Icons.bolt_outlined,
                  value: _hasElectricity,
                  onChanged: (value) {
                    setState(() {
                      _hasElectricity = value;
                      _hasChanges = true;
                    });
                  },
                ),
                ManageListingAmenitySwitchTile(
                  label: 'Security',
                  icon: Icons.security_outlined,
                  value: _hasSecurity,
                  isLast: true,
                  onChanged: (value) {
                    setState(() {
                      _hasSecurity = value;
                      _hasChanges = true;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_hasChanges)
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

