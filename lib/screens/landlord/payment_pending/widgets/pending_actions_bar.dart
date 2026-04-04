import 'package:flutter/material.dart';

class PendingActionsBar extends StatelessWidget {
  final VoidCallback onCheckStatus;
  final VoidCallback onCancel;

  const PendingActionsBar({
    super.key,
    required this.onCheckStatus,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onCheckStatus,
            child: const Text('Check Status'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}
