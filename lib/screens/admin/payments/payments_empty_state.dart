import 'package:flutter/material.dart';

class PaymentsEmptyState extends StatelessWidget {
  const PaymentsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payments_outlined,
            size: 48,
            color: theme.textTheme.bodyMedium?.color,
          ),
          const SizedBox(height: 12),
          Text(
            'No payments yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap Record to add a payment',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
