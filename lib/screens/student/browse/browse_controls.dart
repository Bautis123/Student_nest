import 'package:flutter/material.dart';

import '../../../utils/student_nest_icons.dart';
import 'package:student_nest/core/theme/app_colors.dart';

class BrowseFilterButton extends StatelessWidget {
  const BrowseFilterButton({
    super.key,
    required this.onTap,
    this.foregroundColor = AppDesign.accent,
  });

  final VoidCallback onTap;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppDesign.surface(context),
      borderRadius: BorderRadius.circular(999),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppDesign.surface(context),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppDesign.border(context)),
            boxShadow: [
              BoxShadow(
                color: AppDesign.shadow(context),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StudentNestIcon(
                StudentNestIcons.filter,
                size: 17,
                color: foregroundColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrowseCountPill extends StatelessWidget {
  const BrowseCountPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
      decoration: BoxDecoration(
        color: AppDesign.surface(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppDesign.border(context)),
        boxShadow: [
          BoxShadow(
            color: AppDesign.shadow(context),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppDesign.page(context),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppDesign.shadow(context),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: StudentNestIcon(
                StudentNestIcons.home,
                size: 17,
                color: AppDesign.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppDesign.text(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
