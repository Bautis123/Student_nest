import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';

class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(labels[i]),
                selected: selectedIndex == i,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color:
                      selectedIndex == i
                          ? AppColors.white
                          : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(
                  color:
                      selectedIndex == i ? AppColors.primary : AppColors.border,
                ),
                onSelected: (_) => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}
