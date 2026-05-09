import 'package:flutter/material.dart';
import 'package:student_nest/core/widgets/app_surface_card.dart';
import 'package:student_nest/core/widgets/sn_empty_state.dart';

class EmptyListingsCard extends StatelessWidget {
  const EmptyListingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      radius: 22,
      child: const SNEmptyState(
        icon: Icons.home_work_outlined,
        title: 'No listings here yet',
        subtitle: 'Use Add Listing to create or adjust your filter.',
      ),
    );
  }
}
