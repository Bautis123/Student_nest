import 'package:flutter/material.dart';
import 'settings_tile_icon.dart';
import 'settings_tile_text.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SettingsTileIcon(icon: icon, iconColor: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: SettingsTileText(
                title: title,
                subtitle: subtitle,
                titleColor: titleColor,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
