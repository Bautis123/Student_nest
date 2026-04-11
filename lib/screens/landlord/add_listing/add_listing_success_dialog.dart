import 'package:flutter/material.dart';

import '../../../utils/theme.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppTheme.success,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Listing Submitted!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.dark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your listing has been submitted for admin review. It will go live once approved.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.gray, height: 1.4),
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
            minimumSize: const Size(double.infinity, 44),
          ),
          child: const Text('Back to Dashboard'),
        ),
      ],
    );
  }
}
