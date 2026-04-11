import 'package:flutter/material.dart';

import '../../../utils/theme.dart';

class PaymentsSummaryCard extends StatelessWidget {
  final double totalRevenue;
  final int confirmedCount;
  final int pendingCount;
  final VoidCallback onRecordPressed;

  const PaymentsSummaryCard({
    super.key,
    required this.totalRevenue,
    required this.confirmedCount,
    required this.pendingCount,
    required this.onRecordPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.cardColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Revenue',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                Text(
                  'K${totalRevenue.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.success,
                  ),
                ),
                Text(
                  '$confirmedCount confirmed · $pendingCount pending',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onRecordPressed,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Record'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
        ],
      ),
    );
  }
}
