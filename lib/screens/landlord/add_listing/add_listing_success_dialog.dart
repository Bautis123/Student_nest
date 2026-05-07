import 'package:flutter/material.dart';

import '../../../utils/app_design.dart';

class AddListingSuccessDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AddListingSuccessDialogBody(),
    );
  }
}

class _AddListingSuccessDialogBody extends StatelessWidget {
  const _AddListingSuccessDialogBody();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppDesign.surface(context),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppDesign.accentTint(context),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppDesign.accent,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Listing Submitted!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppDesign.text(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your listing has been submitted for admin review. It will go live once approved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppDesign.muted(context),
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppDesign.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Back to Dashboard'),
        ),
      ],
    );
  }
}
