import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

enum SNBadgeVariant { success, warning, error, info, neutral }

class SNBadge extends StatelessWidget {
  const SNBadge({
    super.key,
    required this.label,
    this.variant = SNBadgeVariant.neutral,
    this.fontSize = 11,
    this.horizontalPadding = 8,
    this.verticalPadding = 4,
    this.radius = AppRadius.pill,
    this.fontWeight = FontWeight.w500,
  });

  final String label;
  final SNBadgeVariant variant;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double radius;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }

  Color get _color {
    switch (variant) {
      case SNBadgeVariant.success:
        return AppColors.success;
      case SNBadgeVariant.warning:
        return AppColors.warning;
      case SNBadgeVariant.error:
        return AppColors.error;
      case SNBadgeVariant.info:
        return AppColors.primaryDark;
      case SNBadgeVariant.neutral:
        return AppColors.textSecondary;
    }
  }
}
