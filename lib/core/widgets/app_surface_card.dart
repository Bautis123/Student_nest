import 'package:flutter/material.dart';

import 'sn_card.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.radius = 8,
    this.color,
    this.borderColor,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      padding: padding,
      margin: margin,
      radius: radius,
      color: color,
      borderColor: borderColor,
      hasShadow: showShadow,
      child: child,
    );
  }
}
