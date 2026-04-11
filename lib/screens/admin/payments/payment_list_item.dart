import 'package:flutter/material.dart';

import '../../../utils/theme.dart';
import 'payment_status_avatar.dart';

class PaymentListItem extends StatelessWidget {
  final dynamic payment;

  const PaymentListItem({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = payment['status'] == 'confirmed';
    final theme = Theme.of(context);
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          PaymentStatusAvatar(isConfirmed: isConfirmed),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['landlord_name'] ?? 'Unknown',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  payment['payment_method']
                          ?.toString()
                          .replaceAll('_', ' ')
                          .toUpperCase() ??
                      '',
                  style: TextStyle(fontSize: 12, color: secondaryTextColor),
                ),
                if (_hasReference)
                  Text(
                    'Ref: ${payment['payment_reference']}',
                    style: TextStyle(fontSize: 11, color: secondaryTextColor),
                  ),
                if (payment['expires_at'] != null)
                  Text(
                    'Expires: ${payment['expires_at'].toString().substring(0, 10)}',
                    style: TextStyle(fontSize: 11, color: secondaryTextColor),
                  ),
              ],
            ),
          ),
          Text(
            'K${(payment['amount'] as num).toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isConfirmed ? AppTheme.success : AppTheme.warning,
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasReference =>
      payment['payment_reference'] != null &&
      payment['payment_reference'].toString().isNotEmpty;
}
