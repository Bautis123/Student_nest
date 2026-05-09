import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';

class ManageListingAmenitySwitchTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const ManageListingAmenitySwitchTile({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(bottom: BorderSide(color: AppDesign.border(context))),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppDesign.accent,
        activeTrackColor: AppDesign.accent.withValues(alpha: 0.26),
        inactiveThumbColor: AppDesign.surface(context),
        inactiveTrackColor: AppDesign.border(context),
        title: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: value ? AppDesign.accent : AppDesign.muted(context),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color:
                    value ? AppDesign.text(context) : AppDesign.muted(context),
                fontWeight: value ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
