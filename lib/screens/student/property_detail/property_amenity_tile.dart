import 'package:flutter/material.dart';
import '../../../utils/student_nest_icons.dart';
import 'package:student_nest/core/theme/app_colors.dart';

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
        color:
            available ? AppDesign.accentTint(context) : AppDesign.page(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              available
                  ? AppDesign.accent.withValues(alpha: 0.16)
                  : AppDesign.border(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          assetIcon != null
              ? StudentNestIcon(
                assetIcon!,
                size: 16,
                color: available ? AppDesign.accent : AppDesign.muted(context),
              )
              : Icon(
                icon,
                size: 16,
                color: available ? AppDesign.accent : AppDesign.muted(context),
              ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color:
                  available ? AppDesign.text(context) : AppDesign.muted(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
