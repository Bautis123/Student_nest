import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../utils/constants.dart';
import '../../../../utils/theme.dart';

class AddListingLocationPage extends StatelessWidget {
  const AddListingLocationPage({
    super.key,
    required this.selectedLocation,
    required this.isLoading,
    required this.onUseMyLocation,
    required this.onMapCreated,
    required this.onLocationSelected,
  });

  final LatLng selectedLocation;
  final bool isLoading;
  final VoidCallback onUseMyLocation;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<LatLng> onLocationSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: AppTheme.primaryLight,
          child: Row(
            children: [
              const Icon(Icons.touch_app_outlined, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tap the map to pin your property or use your current location',
                  style: TextStyle(fontSize: 12, color: AppTheme.primary),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: isLoading ? null : onUseMyLocation,
                icon: const Icon(Icons.my_location, size: 14),
                label: const Text('My Location', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLocation,
              zoom: AppConstants.defaultZoom,
            ),
            onMapCreated: onMapCreated,
            onTap: onLocationSelected,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: selectedLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: const InfoWindow(title: 'Your property'),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lat: ${selectedLocation.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.gray),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
