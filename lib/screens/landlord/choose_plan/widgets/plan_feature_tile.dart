import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';

class PlanFeatureTile extends StatelessWidget {
  final String text;
  final bool premium;

  const PlanFeatureTile({super.key, required this.text, required this.premium});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: premium ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppTheme.dark),
      ),
    );
  }
}
