import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/sn_card.dart';

class OccupancySummaryCard extends StatelessWidget {
  const OccupancySummaryCard({
    super.key,
    required this.total,
    required this.occupied,
    required this.vacant,
  });

  final int total;
  final int occupied;
  final int vacant;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room availability',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metric(
                label: 'Total rooms',
                value: total,
                color: AppColors.primary,
              ),
              _Metric(
                label: 'Occupied',
                value: occupied,
                color: AppColors.textSecondary,
              ),
              _Metric(label: 'Vacant', value: vacant, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
