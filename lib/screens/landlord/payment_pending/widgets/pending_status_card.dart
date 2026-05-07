import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';
import '../../../../widgets/app_surface_card.dart';

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
    final theme = Theme.of(context);
    final title =
        isMobileMoney
            ? 'Enter your PIN on your phone'
            : 'Processing bank payment';

    final text =
        isMobileMoney
            ? 'We sent a payment prompt to the phone number provided. Complete it on your phone to activate the $planTitle plan.'
            : 'We are processing your bank payment details. Please wait while we confirm the transaction.';

    return AppSurfaceCard(
      padding: const EdgeInsets.all(18),
      radius: 18,
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
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

