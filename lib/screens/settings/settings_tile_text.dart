import 'package:flutter/material.dart';
class SettingsTileText extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? titleColor;

  const SettingsTileText({
    super.key,
    required this.title,
    this.subtitle,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: titleColor ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
      ],
    );
  }
}
