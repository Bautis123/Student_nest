import 'package:flutter/material.dart';

class StudentNestIcons {
  static const _base = 'assets/icons/student_nest';

  static const home = '$_base/home.png';
  static const search = '$_base/search.png';
  static const filter = '$_base/filter.png';
  static const mapPin = '$_base/map_pin.png';
  static const building = '$_base/building.png';
  static const room = '$_base/room.png';
  static const bed = '$_base/bed.png';
  static const bath = '$_base/bath.png';
  static const wifi = '$_base/wifi.png';
  static const utilities = '$_base/utilities.png';
  static const lease = '$_base/lease.png';
  static const payment = '$_base/payment.png';
  static const calendar = '$_base/calendar.png';
  static const favorites = '$_base/favorites.png';
  static const chat = '$_base/chat.png';
  static const notifications = '$_base/notifications.png';
  static const profile = '$_base/profile.png';
  static const settings = '$_base/settings.png';
  static const support = '$_base/support.png';
  static const verified = '$_base/verified.png';
  static const save = '$_base/save.png';
  static const share = '$_base/share.png';
  static const location = '$_base/location.png';
  static const university = '$_base/university.png';
  static const safety = '$_base/safety.png';
}

class StudentNestIcon extends StatelessWidget {
  const StudentNestIcon(
    this.asset, {
    super.key,
    this.size = 20,
    this.color,
    this.semanticLabel,
  });

  final String asset;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return ImageIcon(
      AssetImage(asset),
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}
