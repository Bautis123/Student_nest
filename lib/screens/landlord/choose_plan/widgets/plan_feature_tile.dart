import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';

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
          child: Icon(Icons.check_circle, size: 18, color: AppDesign.accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppDesign.text(context),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
