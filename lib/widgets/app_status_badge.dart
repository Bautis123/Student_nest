import 'package:flutter/material.dart';

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 11,
    this.horizontalPadding = 8,
    this.verticalPadding = 4,
    this.radius = 20,
    this.fontWeight = FontWeight.w500,
  });

  final String label;
  final Color color;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double radius;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
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
}
