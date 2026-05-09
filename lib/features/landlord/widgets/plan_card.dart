import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/sn_button.dart';
import 'package:student_nest/core/widgets/sn_card.dart';

class ListingPlan {
  const ListingPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.features,
    this.isRecommended = false,
  });

  final String id;
  final String title;
  final String price;
  final String subtitle;
  final List<String> features;
  final bool isRecommended;
}

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final ListingPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      borderColor: isSelected ? AppColors.primary : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.isRecommended)
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Recommended',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(plan.subtitle),
                  ],
                ),
              ),
              Text(
                plan.price,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final feature in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(feature)),
                ],
              ),
            ),
          const SizedBox(height: 6),
          SNButton(
            label: isSelected ? 'Selected' : 'Select ${plan.title}',
            onPressed: onTap,
            variant:
                isSelected ? SNButtonVariant.primary : SNButtonVariant.outlined,
          ),
        ],
      ),
    );
  }
}
