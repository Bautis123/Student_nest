import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';

class AddListingStepHeader extends StatelessWidget {
  const AddListingStepHeader({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: AppDesign.surfaceDecoration(context, radius: 22),
        child: Row(
          children: [
            _StepIndicator(step: 0, label: 'Details', currentPage: currentPage),
            _StepDivider(currentPage: currentPage, beforeStep: 1),
            _StepIndicator(
              step: 1,
              label: 'Location',
              currentPage: currentPage,
            ),
            _StepDivider(currentPage: currentPage, beforeStep: 2),
            _StepIndicator(step: 2, label: 'Rooms', currentPage: currentPage),
          ],
        ),
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
    final isActive = currentPage == step;
    final isComplete = currentPage > step;
    final color =
        isActive || isComplete ? AppDesign.accent : AppDesign.subtle(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color:
                  isComplete
                      ? AppDesign.accentTint(context)
                      : (isActive ? AppDesign.accent : AppDesign.page(context)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child:
                  isComplete
                      ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppDesign.accent,
                      )
                      : Text(
                        '${step + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : color,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDivider extends StatelessWidget {
  const _StepDivider({required this.currentPage, required this.beforeStep});

  final int currentPage;
  final int beforeStep;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(bottom: 20),
        color:
            currentPage >= beforeStep
                ? AppDesign.accent.withValues(alpha: 0.45)
                : AppDesign.border(context),
      ),
    );
  }
}
