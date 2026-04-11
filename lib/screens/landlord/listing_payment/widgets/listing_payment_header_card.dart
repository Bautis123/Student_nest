import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';
import '../../../../widgets/app_status_badge.dart';
import '../../../../widgets/app_surface_card.dart';

class ListingPaymentHeaderCard extends StatelessWidget {
  final bool isPremium;
  final String amount;

  const ListingPaymentHeaderCard({
    super.key,
    required this.isPremium,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle =
        isPremium
            ? 'Premium listing subscription'
            : 'Basic listing subscription';
    final benefit =
        isPremium
            ? 'Covers 1 year premium badge and boosted placement'
            : 'Covers 1 year standard listing visibility';

    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roma Girls Hostel',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const AppStatusBadge(
                  label: 'Expires in 5 days',
                  color: Color(0xFFB45309),
                  fontSize: 11,
                  horizontalPadding: 10,
                  verticalPadding: 6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: AppTheme.gray,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount to pay',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  benefit,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppTheme.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

