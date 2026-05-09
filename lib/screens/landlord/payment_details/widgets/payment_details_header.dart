import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/app_surface_card.dart';

class PaymentDetailsHeader extends StatelessWidget {
  final String amount;
  final String paymentLabel;

  const PaymentDetailsHeader({
    super.key,
    required this.amount,
    required this.paymentLabel,
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
            'Enter payment details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            paymentLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: AppDesign.muted(context),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            amount,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
