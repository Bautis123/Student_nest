import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';

class ReceiptDetailsCard extends StatelessWidget {
  final String planTitle;
  final String paymentMethod;
  final String amount;
  final String nextExpiry;

  const ReceiptDetailsCard({
    super.key,
    required this.planTitle,
    required this.paymentMethod,
    required this.amount,
    required this.nextExpiry,
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
        children: [
          _row('Property', 'Roma Girls Hostel'),
          const SizedBox(height: 12),
          _row('Plan', planTitle),
          const SizedBox(height: 12),
          _row('Amount paid', amount),
          const SizedBox(height: 12),
          _row('Payment method', paymentMethod),
          const SizedBox(height: 12),
          _row('Transaction ref', 'SN-2026-00124'),
          const SizedBox(height: 12),
          _row('Next expiry', nextExpiry),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.gray)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.dark,
          ),
        ),
      ],
    );
  }
}
