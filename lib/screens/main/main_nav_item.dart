import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';

import '../../utils/student_nest_icons.dart';

class MainNavItem extends StatelessWidget {
  const MainNavItem({
    super.key,
    required this.label,
    required this.asset,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 34 : 30,
            height: selected ? 34 : 30,
            decoration: BoxDecoration(
              color: selected ? selectedColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: StudentNestIcon(
                asset,
                size: selected ? 17 : 20,
                color: selected ? AppColors.white : color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
