import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/property.dart';
import 'package:student_nest/core/constants/app_constants.dart';
import 'package:student_nest/core/utils/formatters.dart';

class PropertyRouteActions {
  const PropertyRouteActions();

  String _formatCoord(double value) => Formatters.coordinate(value);

  Future<void> openInMaps({
    required BuildContext context,
    required Property property,
  }) async {
    final originLat = property.latitude;
    final originLng = property.longitude;
    final destinationLat =
        property.resolvedSchoolLat ?? AppConstants.defaultLat;
    final destinationLng =
        property.resolvedSchoolLng ?? AppConstants.defaultLng;

    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIos) {
      _showIosMapsPicker(
        context: context,
        originLat: originLat,
        originLng: originLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
      );
      return;
    }

    await _launchExternalUrl(
      context: context,
      uri: Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${_formatCoord(originLat)},${_formatCoord(originLng)}'
        '&destination=${_formatCoord(destinationLat)},${_formatCoord(destinationLng)}'
        '&travelmode=walking',
      ),
    );
  }

  Future<void> openInYango({
    required BuildContext context,
    required Property property,
  }) async {
    try {
      final hasLocation = await Geolocator.isLocationServiceEnabled();
      if (!context.mounted) return;
      if (!hasLocation) {
        _showInfo(
          context,
          'Location services are off. Turn them on and try again.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!context.mounted) return;
      if (permission == LocationPermission.denied) {
        _showInfo(context, 'Location permission denied.');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showInfo(
          context,
          'Location permission denied forever. Enable it in settings.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!context.mounted) return;

      final destinationLat = property.latitude;
      final destinationLng = property.longitude;
      final startLat = position.latitude;
      final startLng = position.longitude;

      final yangoAppUri = Uri.parse(
        'yandextaxi://route?'
        'start-lat=${_formatCoord(startLat)}&'
        'start-lon=${_formatCoord(startLng)}&'
        'end-lat=${_formatCoord(destinationLat)}&'
        'end-lon=${_formatCoord(destinationLng)}&'
        'tariffClass=econom',
      );

      final yangoWebUri =
          Uri.https('3.redirect.appmetrica.yandex.com', '/route', {
            'start-lat': _formatCoord(startLat),
            'start-lon': _formatCoord(startLng),
            'end-lat': _formatCoord(destinationLat),
            'end-lon': _formatCoord(destinationLng),
            'tariffClass': 'econom',
            'ref': 'studentnest',
            'lang': 'en',
            'appmetrica_tracking_id': '1178268795219780156',
          });

      if (await canLaunchUrl(yangoAppUri)) {
        if (!context.mounted) return;
        await _launchExternalUrl(context: context, uri: yangoAppUri);
      } else {
        if (!context.mounted) return;
        await _launchExternalUrl(context: context, uri: yangoWebUri);
      }
    } catch (_) {
      if (!context.mounted) return;
      _showInfo(context, 'Could not get your current location right now.');
    }
  }

  Future<void> _launchExternalUrl({
    required BuildContext context,
    required Uri uri,
  }) async {
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!didLaunch && context.mounted) {
      _showInfo(context, 'Could not open the app right now.');
    }
  }

  void _showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showIosMapsPicker({
    required BuildContext context,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) {
    final appleMapsUri = Uri.parse(
      'http://maps.apple.com/?saddr=${_formatCoord(originLat)},${_formatCoord(originLng)}'
      '&daddr=${_formatCoord(destinationLat)},${_formatCoord(destinationLng)}'
      '&dirflg=w',
    );
    final googleMapsUri = Uri.parse(
      'comgooglemaps://?saddr=${_formatCoord(originLat)},${_formatCoord(originLng)}'
      '&daddr=${_formatCoord(destinationLat)},${_formatCoord(destinationLng)}'
      '&directionsmode=walking',
    );

    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Apple Maps'),
                onTap: () async {
                  Navigator.pop(context);
                  if (!context.mounted) return;
                  await _launchExternalUrl(context: context, uri: appleMapsUri);
                },
              ),
              FutureBuilder<bool>(
                future: canLaunchUrl(googleMapsUri),
                builder: (context, snapshot) {
                  if (snapshot.data != true) return const SizedBox.shrink();
                  return ListTile(
                    leading: const Icon(Icons.map_outlined),
                    title: const Text('Google Maps'),
                    onTap: () async {
                      Navigator.pop(context);
                      if (!context.mounted) return;
                      await _launchExternalUrl(
                        context: context,
                        uri: googleMapsUri,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
