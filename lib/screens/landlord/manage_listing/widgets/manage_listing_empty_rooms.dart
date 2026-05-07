import 'package:flutter/material.dart';

import '../../../../utils/app_design.dart';
import '../../../../utils/student_nest_icons.dart';

class ManageListingEmptyRooms extends StatelessWidget {
  const ManageListingEmptyRooms({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppDesign.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppDesign.border(context)),
      ),
      child: Center(
        child: Column(
          children: [
            const StudentNestIcon(
              StudentNestIcons.bed,
              size: 48,
              color: AppDesign.accent,
            ),
            const SizedBox(height: 12),
            Text(
              'No room types yet',
              style: TextStyle(
                color: AppDesign.muted(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
