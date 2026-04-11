import 'package:flutter/material.dart';

class SettingsTileIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const SettingsTileIcon({
    super.key,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }
}
