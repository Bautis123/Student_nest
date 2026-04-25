import 'package:flutter/material.dart';

import '../../../../utils/student_nest_icons.dart';
import '../../../../utils/theme.dart';

class ManageListingEmptyRooms extends StatelessWidget {
  const ManageListingEmptyRooms({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Center(
        child: Column(
          children: [
            StudentNestIcon(
              StudentNestIcons.bed,
              size: 48,
              color: AppTheme.gray,
            ),
            SizedBox(height: 12),
            Text(
              'No room types yet',
              style: TextStyle(
                color: AppTheme.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
