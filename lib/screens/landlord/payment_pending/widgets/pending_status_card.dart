import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';

class PendingStatusCard extends StatelessWidget {
  final bool isMobileMoney;
  final String planTitle;

  const PendingStatusCard({
    super.key,
    required this.isMobileMoney,
    required this.planTitle,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        isMobileMoney
            ? 'Enter your PIN on your phone'
            : 'Processing bank payment';

    final text =
        isMobileMoney
            ? 'We sent a payment prompt to the phone number provided. Complete it on your phone to activate the $planTitle plan.'
            : 'We are processing your bank payment details. Please wait while we confirm the transaction.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.gray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
