import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';

import '../../../utils/student_nest_icons.dart';

class SchoolSelectorButton extends StatelessWidget {
  const SchoolSelectorButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppDesign.surface(context),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppDesign.border(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StudentNestIcon(
                StudentNestIcons.university,
                size: 16,
                color: AppDesign.accent,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppDesign.text(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppDesign.subtle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SchoolPickerSheet extends StatelessWidget {
  const SchoolPickerSheet({
    super.key,
    required this.schools,
    required this.selectedSchoolId,
    required this.allSchoolsValue,
  });

  final List<Map<String, dynamic>> schools;
  final String? selectedSchoolId;
  final String allSchoolsValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesign.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppDesign.border(context),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select school',
              style: TextStyle(
                color: AppDesign.text(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _SchoolOption(
              title: 'All schools',
              subtitle: 'Show every boarding house',
              isSelected: selectedSchoolId == null,
              onTap: () => Navigator.pop(context, allSchoolsValue),
            ),
            for (final school in schools)
              _SchoolOption(
                title: school['name']?.toString() ?? 'School',
                subtitle: school['area']?.toString() ?? 'Nearby listings',
                isSelected: selectedSchoolId == school['id']?.toString(),
                onTap: () => Navigator.pop(context, school['id']?.toString()),
              ),
          ],
        ),
      ),
    );
  }
}

class _SchoolOption extends StatelessWidget {
  const _SchoolOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppDesign.surface(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppDesign.accentTint(context)
                      : AppDesign.page(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: StudentNestIcon(
                  StudentNestIcons.university,
                  size: 17,
                  color:
                      isSelected ? AppDesign.accent : AppDesign.muted(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppDesign.text(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppDesign.muted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppDesign.accent,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
