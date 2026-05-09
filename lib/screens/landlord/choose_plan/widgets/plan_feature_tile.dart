import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_theme.dart';

class PlanFeatureTile extends StatelessWidget {
  final String text;

  const PlanFeatureTile({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.dark,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
