import 'package:flutter/material.dart';
import '../../../utils/student_nest_icons.dart';
import '../../../utils/theme.dart';

class PropertyAmenityTile extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? assetIcon;
  final bool available;

  const PropertyAmenityTile({
    super.key,
    required this.label,
    this.icon,
    this.assetIcon,
    required this.available,
  }) : assert(icon != null || assetIcon != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: available ? AppTheme.primaryLight : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              available
                  ? AppTheme.primary.withValues(alpha: 0.16)
                  : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          assetIcon != null
              ? StudentNestIcon(
                assetIcon!,
                size: 16,
                color: available ? AppTheme.primary : AppTheme.gray,
              )
              : Icon(
                icon,
                size: 16,
                color: available ? AppTheme.primary : AppTheme.gray,
              ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: available ? const Color(0xFF7B8494) : AppTheme.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
