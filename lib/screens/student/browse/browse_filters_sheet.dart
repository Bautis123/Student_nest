import 'package:flutter/material.dart';

import 'package:student_nest/core/constants/app_strings.dart';
import 'package:student_nest/core/theme/app_theme.dart';
import 'package:student_nest/core/widgets/sn_button.dart';
import 'browse_filters.dart';

class BrowseFiltersSheet {
  const BrowseFiltersSheet._();

  static Future<Set<BrowseFilter>?> show({
    required BuildContext context,
    required Set<BrowseFilter> selectedFilters,
  }) {
    return showModalBottomSheet<Set<BrowseFilter>>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        var tempSelected = Set<BrowseFilter>.from(selectedFilters);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: BrowseFilter.values
                        .map((filter) {
                          final selected = tempSelected.contains(filter);
                          return FilterChip(
                            label: Text(filter.label),
                            selected: selected,
                            onSelected: (isSelected) {
                              setModalState(() {
                                if (isSelected) {
                                  tempSelected.add(filter);
                                } else {
                                  tempSelected.remove(filter);
                                }
                              });
                            },
                            selectedColor: AppTheme.primary.withValues(
                              alpha: 0.18,
                            ),
                            side: BorderSide(
                              color:
                                  selected
                                      ? AppTheme.primary.withValues(alpha: 0.45)
                                      : AppTheme.border,
                            ),
                            checkmarkColor: AppTheme.primary,
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempSelected = {BrowseFilter.suggested};
                          });
                        },
                        child: const Text('Reset'),
                      ),
                      const Spacer(),
                      SNButton(
                        label: AppStrings.apply,
                        onPressed: () {
                          Navigator.pop(
                            context,
                            BrowseFilterEngine.normalizeSelectedFilters(
                              tempSelected,
                            ),
                          );
                        },
                        fullWidth: false,
                        height: 44,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
