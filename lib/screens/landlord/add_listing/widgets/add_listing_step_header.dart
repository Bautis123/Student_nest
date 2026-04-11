import 'package:flutter/material.dart';

import '../../../../utils/theme.dart';

class AddListingStepHeader extends StatelessWidget {
  const AddListingStepHeader({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _StepIndicator(step: 0, label: 'Details', currentPage: currentPage),
          const _StepDivider(),
          _StepIndicator(step: 1, label: 'Location', currentPage: currentPage),
          const _StepDivider(),
          _StepIndicator(step: 2, label: 'Rooms', currentPage: currentPage),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.step,
    required this.label,
    required this.currentPage,
  });

  final int step;
  final String label;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final isActive = currentPage >= step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppTheme.primary : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDivider extends StatelessWidget {
  const _StepDivider();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(bottom: 20),
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }
}
