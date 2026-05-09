import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';
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
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: iconColor.withValues(
          alpha: AppDesign.isDark(context) ? 0.18 : 0.11,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          assetIcon != null
              ? StudentNestIcon(assetIcon!, color: iconColor, size: 18)
              : Icon(icon, color: iconColor, size: 18),
    );
  }
}
