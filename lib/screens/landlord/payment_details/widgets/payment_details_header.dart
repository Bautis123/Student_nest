import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';

class PaymentDetailsHeader extends StatelessWidget {
  final String amount;
  final String paymentLabel;

  const PaymentDetailsHeader({
    super.key,
    required this.amount,
    required this.paymentLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter payment details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            paymentLabel,
            style: const TextStyle(fontSize: 13, color: AppTheme.gray),
          ),
          const SizedBox(height: 14),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }
}
