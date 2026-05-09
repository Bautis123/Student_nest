import 'package:flutter/material.dart';
import 'package:student_nest/core/widgets/sn_button.dart';

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
          child: SNButton(label: 'Check Status', onPressed: onCheckStatus),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SNButton(
            label: 'Cancel',
            onPressed: onCancel,
            variant: SNButtonVariant.ghost,
          ),
        ),
      ],
    );
  }
}
