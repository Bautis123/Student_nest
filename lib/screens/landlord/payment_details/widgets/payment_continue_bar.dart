import 'package:flutter/material.dart';
import 'package:student_nest/core/widgets/app_bottom_action_bar.dart';
import 'package:student_nest/core/widgets/sn_button.dart';

class PaymentContinueBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback onContinue;

  const PaymentContinueBar({
    super.key,
    required this.enabled,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomActionBar(
      child: SizedBox(
        width: double.infinity,
        child: SNButton(
          label: 'Continue',
          onPressed: enabled ? onContinue : null,
        ),
      ),
    );
  }
}
