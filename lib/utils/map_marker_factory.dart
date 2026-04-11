import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerFactory {
  static Future<BitmapDescriptor> houseMarker() {
    return _buildMarker(
      icon: Icons.home_rounded,
      backgroundColor: const Color(0xFF166534),
      iconColor: Colors.white,
    );
  }

  static Future<BitmapDescriptor> schoolMarker() {
    return _buildMarker(
      icon: Icons.school_rounded,
      backgroundColor: const Color(0xFFF59E0B),
      iconColor: Colors.white,
    );
  }

  static Future<BitmapDescriptor> _buildMarker({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) async {
    const size = 120.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = backgroundColor;

    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.4, paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 56,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: iconColor,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );

    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
}
