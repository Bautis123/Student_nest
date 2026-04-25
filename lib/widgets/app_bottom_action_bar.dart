import 'package:flutter/material.dart';

class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
    this.withTopBorder = true,
    this.backgroundColor = Colors.transparent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool withTopBorder;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border:
            withTopBorder
                ? const Border(
                  top: BorderSide(color: Colors.transparent, width: 0),
                )
                : null,
        boxShadow:
            withTopBorder
                ? [
                  BoxShadow(
                    color: const Color(0xFF667085).withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ]
                : null,
      ),
      child: child,
    );
  }
}
