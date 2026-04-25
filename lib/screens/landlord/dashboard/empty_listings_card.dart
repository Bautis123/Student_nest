import 'package:flutter/material.dart';
import '../../../utils/student_nest_icons.dart';
import '../../../utils/theme.dart';
import '../../../widgets/app_surface_card.dart';

class EmptyListingsCard extends StatelessWidget {
  const EmptyListingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: Column(
          children: [
            StudentNestIcon(
              StudentNestIcons.building,
              size: 48,
              color: AppTheme.gray,
            ),
            SizedBox(height: 12),
            Text(
              'No listings yet',
              style: TextStyle(
                color: AppTheme.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tap Add New to create your first listing',
              style: TextStyle(color: AppTheme.gray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
