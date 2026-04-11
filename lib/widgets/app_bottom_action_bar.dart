import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
        border: withTopBorder
            ? const Border(top: BorderSide(color: AppTheme.border))
            : null,
      ),
      child: child,
    );
  }
}
