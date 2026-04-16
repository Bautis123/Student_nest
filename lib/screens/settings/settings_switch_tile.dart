import 'package:flutter/material.dart';
import 'settings_tile_icon.dart';
import 'settings_tile_text.dart';

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SettingsTileIcon(icon: icon, iconColor: iconColor),
          const SizedBox(width: 12),
          Expanded(child: SettingsTileText(title: title, subtitle: subtitle)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
