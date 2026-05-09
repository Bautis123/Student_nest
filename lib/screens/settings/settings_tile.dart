import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'settings_tile_icon.dart';
import 'settings_tile_text.dart';

class SettingsTile extends StatelessWidget {
  final IconData? icon;
  final String? assetIcon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    this.icon,
    this.assetIcon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  }) : assert(icon != null || assetIcon != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            SettingsTileIcon(
              icon: icon,
              assetIcon: assetIcon,
              iconColor: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SettingsTileText(
                title: title,
                subtitle: subtitle,
                titleColor: titleColor,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppDesign.subtle(context),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
