import 'package:flutter/material.dart';
import '../../../utils/app_design.dart';
import '../../../utils/student_nest_icons.dart';
import '../../../widgets/app_surface_card.dart';

class EmptyListingsCard extends StatelessWidget {
  const EmptyListingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(32),
      radius: 22,
      child: Center(
        child: Column(
          children: [
            const StudentNestIcon(
              StudentNestIcons.building,
              size: 48,
              color: AppDesign.accent,
            ),
            const SizedBox(height: 12),
            Text(
              'No listings here yet',
              style: TextStyle(
                color: AppDesign.text(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Use Add Listing to create or adjust your filter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppDesign.muted(context), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
