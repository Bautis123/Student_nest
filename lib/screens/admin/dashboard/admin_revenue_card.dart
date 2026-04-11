import 'package:flutter/material.dart';

import '../../../utils/theme.dart';

class AdminRevenueCard extends StatelessWidget {
  final dynamic totalRevenue;

  const AdminRevenueCard({super.key, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    final amount = (totalRevenue ?? 0).toStringAsFixed(2);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Revenue',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
              Text(
                'K$amount',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
