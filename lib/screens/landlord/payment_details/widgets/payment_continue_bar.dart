import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
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
