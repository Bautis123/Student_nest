import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class PropertyAmenityTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool available;

  const PropertyAmenityTile({
    super.key,
    required this.label,
    required this.icon,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: available ? AppTheme.primaryLight : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              available
                  ? AppTheme.primary.withValues(alpha: 0.3)
                  : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: available ? AppTheme.primary : AppTheme.gray,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: available ? AppTheme.primary : AppTheme.gray,
              fontWeight: available ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
