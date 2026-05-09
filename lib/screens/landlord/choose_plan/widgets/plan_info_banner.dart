import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_theme.dart';

class PlanInfoBanner extends StatelessWidget {
  final bool isPremium;

  const PlanInfoBanner({super.key, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final text =
        isPremium
            ? 'Premium listings get a premium badge and stronger placement in student suggestions.'
            : 'Basic listings stay visible on the platform with standard placement.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.dark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
