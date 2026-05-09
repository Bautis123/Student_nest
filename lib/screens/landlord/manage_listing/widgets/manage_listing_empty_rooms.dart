import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/sn_empty_state.dart';

class ManageListingEmptyRooms extends StatelessWidget {
  const ManageListingEmptyRooms({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppDesign.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppDesign.border(context)),
      ),
      child: const SNEmptyState(
        icon: Icons.bed_outlined,
        title: 'No room types yet',
        subtitle: 'Add room types so students can see availability.',
      ),
    );
  }
}
