import 'package:flutter/material.dart';
import '../../../../widgets/app_info_row.dart';
import '../../../../widgets/app_surface_card.dart';

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
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        children: [
          const AppInfoRow(label: 'Property', value: 'Roma Girls Hostel'),
          const SizedBox(height: 12),
          AppInfoRow(label: 'Plan', value: planTitle),
          const SizedBox(height: 12),
          AppInfoRow(label: 'Amount paid', value: amount),
          const SizedBox(height: 12),
          AppInfoRow(label: 'Payment method', value: paymentMethod),
          const SizedBox(height: 12),
          const AppInfoRow(label: 'Transaction ref', value: 'SN-2026-00124'),
          const SizedBox(height: 12),
          AppInfoRow(label: 'Next expiry', value: nextExpiry),
        ],
      ),
    );
  }
}

