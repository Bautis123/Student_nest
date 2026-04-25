import 'package:flutter/material.dart';

import '../../utils/student_nest_icons.dart';

class SettingsTileIcon extends StatelessWidget {
  final IconData? icon;
  final String? assetIcon;
  final Color iconColor;

  const SettingsTileIcon({
    super.key,
    this.icon,
    this.assetIcon,
    required this.iconColor,
  }) : assert(icon != null || assetIcon != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          assetIcon != null
              ? StudentNestIcon(assetIcon!, color: iconColor, size: 18)
              : Icon(icon, color: iconColor, size: 18),
    );
  }
}
