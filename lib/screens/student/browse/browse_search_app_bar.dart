import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';

import '../../../utils/student_nest_icons.dart';

class BrowseSearchAppBar extends StatelessWidget {
  const BrowseSearchAppBar({
    super.key,
    required this.locationLabel,
    required this.onSearchChanged,
    required this.onOpenFilters,
  });

  final String locationLabel;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 126,
      floating: false,
      pinned: true,
      backgroundColor: AppDesign.surface(context),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: 62,
      titleSpacing: 16,
      title: Row(
        children: [
          const StudentNestIcon(
            StudentNestIcons.mapPin,
            size: 15,
            color: AppDesign.accent,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              locationLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppDesign.muted(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ColoredBox(
          color: AppDesign.surface(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppDesign.surface(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppDesign.shadow(context),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: onSearchChanged,
                style: TextStyle(
                  color: AppDesign.text(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by location or name',
                  hintStyle: TextStyle(
                    color: AppDesign.muted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.search_rounded,
                      size: 32,
                      color: AppDesign.muted(context),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 54,
                    minHeight: 52,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
                    child: Material(
                      color: AppDesign.accent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: onOpenFilters,
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.tune_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 17),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
