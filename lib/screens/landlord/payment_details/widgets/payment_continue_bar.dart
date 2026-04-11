import 'package:flutter/material.dart';
import '../../../../widgets/app_bottom_action_bar.dart';

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
        child: ElevatedButton(
          onPressed: enabled ? onContinue : null,
          child: const Text('Continue'),
        ),
      ),
    );
  }
}

