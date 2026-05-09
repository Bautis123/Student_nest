import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/sn_empty_state.dart';

class ManageListingEmptyPhotos extends StatelessWidget {
  const ManageListingEmptyPhotos({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppDesign.surface(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const SNEmptyState(
        icon: Icons.photo_library_outlined,
        title: 'No photos yet',
        subtitle: 'Tap Add Photos to upload.',
      ),
    );
  }
}
