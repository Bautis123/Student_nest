import 'package:flutter/material.dart';

import '../../../../utils/app_design.dart';

class ManageListingEmptyPhotos extends StatelessWidget {
  const ManageListingEmptyPhotos({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppDesign.surface(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: AppDesign.lightMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No photos yet',
              style: TextStyle(
                color: AppDesign.muted(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap Add Photos to upload',
              style: TextStyle(color: AppDesign.muted(context), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

