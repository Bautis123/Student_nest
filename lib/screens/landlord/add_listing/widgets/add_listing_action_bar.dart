import 'package:flutter/material.dart';

import '../../../../utils/app_design.dart';
import '../../../../widgets/app_bottom_action_bar.dart';

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
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: AppDesign.accent,
                  side: const BorderSide(color: AppDesign.accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          if (currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : (currentPage < 2 ? onNext : onSubmit),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesign.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppDesign.accent.withValues(alpha: 0.55),
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(currentPage < 2 ? 'Next' : 'Submit listing'),
            ),
          ),
        ],
      ),
    );
  }
}

