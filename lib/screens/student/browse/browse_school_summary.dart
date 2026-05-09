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
    return SliverPersistentHeader(
      pinned: true,
      delegate: _BrowseSchoolSummaryDelegate(
        selectedSchoolLabel: selectedSchoolLabel,
        listingCount: listingCount,
        onSchoolTap: onSchoolTap,
      ),
    );
  }
}

class _BrowseSchoolSummaryDelegate extends SliverPersistentHeaderDelegate {
  const _BrowseSchoolSummaryDelegate({
    required this.selectedSchoolLabel,
    required this.listingCount,
    required this.onSchoolTap,
  });

  final String selectedSchoolLabel;
  final int listingCount;
  final VoidCallback onSchoolTap;

  @override
  double get minExtent => 68;

  @override
  double get maxExtent => 68;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppDesign.page(context),
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

  @override
  bool shouldRebuild(covariant _BrowseSchoolSummaryDelegate oldDelegate) {
    return true;
  }
}
