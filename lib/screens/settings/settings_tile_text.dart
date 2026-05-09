import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: titleColor ?? AppDesign.text(context),
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: TextStyle(
              color: AppDesign.muted(context),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
          ),
      ],
    );
  }
}
