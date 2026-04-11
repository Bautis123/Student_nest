import 'package:flutter/material.dart';

import '../../../../utils/theme.dart';

class ListingAmenitySwitchTile extends StatelessWidget {
  const ListingAmenitySwitchTile({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
        title: Row(
          children: [
            Icon(icon, size: 18, color: value ? AppTheme.primary : AppTheme.gray),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: value ? AppTheme.dark : AppTheme.gray,
                fontWeight: value ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

