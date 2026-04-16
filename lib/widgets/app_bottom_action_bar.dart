import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 14),
    this.withTopBorder = true,
    this.backgroundColor = AppTheme.white,
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
                  top: BorderSide(color: AppTheme.border, width: 1),
                )
                : null,
        boxShadow:
            withTopBorder
                ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ]
                : null,
      ),
      child: child,
    );
  }
}
