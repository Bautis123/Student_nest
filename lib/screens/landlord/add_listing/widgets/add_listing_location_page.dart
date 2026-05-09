import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:student_nest/core/constants/app_constants.dart';
import 'package:student_nest/core/constants/app_strings.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/utils/formatters.dart';
import 'package:student_nest/core/widgets/app_surface_card.dart';
import 'package:student_nest/core/widgets/sn_button.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              color: AppDesign.text(context),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pin your property so students can find it easily.',
            style: TextStyle(
              color: AppDesign.muted(context),
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          AppSurfaceCard(
            padding: const EdgeInsets.all(14),
            radius: 22,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppDesign.accentTint(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.touch_app_outlined,
                    color: AppDesign.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap the map to pin your property',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppDesign.text(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SNButton(
                  label: AppStrings.useMyLocation,
                  onPressed: isLoading ? null : onUseMyLocation,
                  leadingIcon: Icons.my_location,
                  fullWidth: false,
                  height: 36,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GoogleMap(
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
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                        infoWindow: const InfoWindow(title: 'Your property'),
                      ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                  ),
                  if (isLoading)
                    Container(
                      color: AppDesign.page(context),
                      child: const _MapPlaceholder(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppSurfaceCard(
            padding: const EdgeInsets.all(14),
            radius: 18,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppDesign.accent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pinned location',
                        style: TextStyle(
                          color: AppDesign.text(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lat: ${Formatters.coordinate(selectedLocation.latitude)}, Lng: ${Formatters.coordinate(selectedLocation.longitude)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppDesign.muted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 108),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppDesign.accentTint(context),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppDesign.accent,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Loading map...',
            style: TextStyle(
              color: AppDesign.muted(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
