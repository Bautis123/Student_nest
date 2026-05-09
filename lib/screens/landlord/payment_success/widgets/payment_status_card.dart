import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/theme/app_theme.dart';
import 'package:student_nest/core/widgets/app_surface_card.dart';

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
    final theme = Theme.of(context);
    return AppSurfaceCard(
      padding: const EdgeInsets.all(18),
      radius: 18,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppTheme.success,
              size: 40,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Payment successful',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$planTitle plan activated successfully.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: AppTheme.gray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            amount,
            style: theme.textTheme.headlineMedium?.copyWith(
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
