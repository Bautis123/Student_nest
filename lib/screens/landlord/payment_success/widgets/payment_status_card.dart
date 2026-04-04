import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';

class PaymentStatusCard extends StatelessWidget {
  final String planTitle;
  final String amount;

  const PaymentStatusCard({
    super.key,
    required this.planTitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppTheme.success,
              size: 40,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Payment successful',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$planTitle plan activated successfully.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.gray,
              height: 1.5,
            ),
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
