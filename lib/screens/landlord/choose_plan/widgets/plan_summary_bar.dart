import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';
import '../../../../widgets/app_bottom_action_bar.dart';
import '../../../../widgets/app_info_row.dart';

class PlanSummaryBar extends StatelessWidget {
  final String title;
  final String price;
  final bool isPremium;
  final VoidCallback onContinue;

  const PlanSummaryBar({
    super.key,
    required this.title,
    required this.price,
    required this.isPremium,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomActionBar(
      child: Column(
        children: [
          AppInfoRow(label: 'Selected plan', value: title),
          const SizedBox(height: 6),
          AppInfoRow(
            label: 'Price',
            value: price,
            valueColor: isPremium ? AppTheme.success : AppTheme.dark,
            valueWeight: FontWeight.w700,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

