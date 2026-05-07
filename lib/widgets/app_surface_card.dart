import 'package:flutter/material.dart';
import '../utils/app_design.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.radius = 18,
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
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppDesign.surface(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppDesign.border(context)),
        boxShadow: showShadow ? AppDesign.softShadow(context) : null,
      ),
      child: child,
    );
  }
}
