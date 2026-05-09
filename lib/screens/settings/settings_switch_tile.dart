import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'settings_tile_icon.dart';
import 'settings_tile_text.dart';

class SettingsSwitchTile extends StatelessWidget {
  final IconData? icon;
  final String? assetIcon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    this.icon,
    this.assetIcon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  }) : assert(icon != null || assetIcon != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SettingsTileIcon(
            icon: icon,
            assetIcon: assetIcon,
            iconColor: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(child: SettingsTileText(title: title, subtitle: subtitle)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppDesign.accent,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppDesign.border(context),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
