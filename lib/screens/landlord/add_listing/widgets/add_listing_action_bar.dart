import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/app_bottom_action_bar.dart';
import 'package:student_nest/core/widgets/sn_button.dart';

class AddListingActionBar extends StatelessWidget {
  const AddListingActionBar({
    super.key,
    required this.currentPage,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  final int currentPage;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppBottomActionBar(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      backgroundColor: AppDesign.surface(context),
      child: Row(
        children: [
          if (currentPage > 0)
            Expanded(
              child: SNButton(
                label: 'Back',
                onPressed: onBack,
                variant: SNButtonVariant.outlined,
                height: 50,
              ),
            ),
          if (currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SNButton(
              label: currentPage < 2 ? 'Next' : 'Submit listing',
              onPressed: currentPage < 2 ? onNext : onSubmit,
              isLoading: isLoading,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}
