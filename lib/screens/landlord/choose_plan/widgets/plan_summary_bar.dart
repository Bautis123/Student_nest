import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';

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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          _summaryRow('Selected plan', title, AppTheme.dark),
          const SizedBox(height: 6),
          _summaryRow(
            'Price',
            price,
            isPremium ? AppTheme.success : AppTheme.dark,
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

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.gray)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
