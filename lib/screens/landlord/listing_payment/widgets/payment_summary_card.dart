import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';

class PaymentSummaryCard extends StatelessWidget {
  final String planTitle;
  final String amount;
  final VoidCallback onPayNow;

  const PaymentSummaryCard({
    super.key,
    required this.planTitle,
    required this.amount,
    required this.onPayNow,
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
            'Payment summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _row('Plan', planTitle),
          const SizedBox(height: 8),
          _row('Listing fee', amount),
          const SizedBox(height: 8),
          _row('Processing', 'Included'),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _row('Total', amount, bold: true, green: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPayNow,
              child: const Text('Pay now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    bool green = false,
  }) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.gray)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: green ? AppTheme.success : AppTheme.dark,
          ),
        ),
      ],
    );
  }
}
