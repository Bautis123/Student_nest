import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/app_info_row.dart';
import 'package:student_nest/core/widgets/app_surface_card.dart';
import 'package:student_nest/core/widgets/sn_button.dart';

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
    final theme = Theme.of(context);
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          AppInfoRow(label: 'Plan', value: planTitle),
          const SizedBox(height: 8),
          AppInfoRow(label: 'Listing fee', value: amount),
          const SizedBox(height: 8),
          const AppInfoRow(label: 'Processing', value: 'Included'),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          AppInfoRow(
            label: 'Total',
            value: amount,
            valueColor: AppColors.success,
            valueWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SNButton(label: 'Pay now', onPressed: onPayNow),
          ),
        ],
      ),
    );
  }
}
