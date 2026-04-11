import 'package:flutter/material.dart';

import '../../../utils/theme.dart';

class AdminFilterToggle extends StatelessWidget {
  final bool isFirstSelected;
  final String firstLabel;
  final String secondLabel;
  final VoidCallback onFirstTap;
  final VoidCallback onSecondTap;
  final int secondBadgeCount;

  const AdminFilterToggle({
    super.key,
    required this.isFirstSelected,
    required this.firstLabel,
    required this.secondLabel,
    required this.onFirstTap,
    required this.onSecondTap,
    this.secondBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.cardColor,
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: firstLabel,
              selected: isFirstSelected,
              onTap: onFirstTap,
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: secondLabel,
              selected: !isFirstSelected,
              onTap: onSecondTap,
              badgeCount: secondBadgeCount,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedBackground = colorScheme.primary;
    final unselectedText = theme.textTheme.bodyMedium?.color ?? AppTheme.gray;
    final badgeBackground = selected ? theme.cardColor : AppTheme.error;
    final badgeTextColor = selected ? AppTheme.error : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? colorScheme.onPrimary : unselectedText,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: badgeBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
