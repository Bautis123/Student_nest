import 'package:flutter/material.dart';
import '../../../../utils/app_design.dart';
import '../../../../utils/theme.dart';
import '../../../../widgets/app_bottom_action_bar.dart';

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
          _summaryRow(label: 'Selected plan', value: title),
          const SizedBox(height: 6),
          _summaryRow(
            label: 'Price',
            value: price,
            valueColor: isPremium ? AppTheme.primary : null,
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

  Widget _summaryRow({
    required String label,
    required String value,
    Color? valueColor,
    FontWeight valueWeight = FontWeight.w700,
  }) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppDesign.muted(context),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: valueWeight,
                color: valueColor ?? AppDesign.text(context),
              ),
            ),
          ],
        );
      },
    );
  }
}

