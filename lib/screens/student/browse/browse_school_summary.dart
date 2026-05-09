import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';

import 'school_picker_sheet.dart';

class BrowseSchoolSummary extends StatelessWidget {
  const BrowseSchoolSummary({
    super.key,
    required this.selectedSchoolLabel,
    required this.listingCount,
    required this.onSchoolTap,
  });

  final String selectedSchoolLabel;
  final int listingCount;
  final VoidCallback onSchoolTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: SchoolSelectorButton(
                label: selectedSchoolLabel,
                onTap: onSchoolTap,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                '$listingCount boarding houses',
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppDesign.muted(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
