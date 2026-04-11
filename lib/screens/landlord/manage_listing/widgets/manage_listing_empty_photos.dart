import 'package:flutter/material.dart';

import '../../../../utils/theme.dart';

class ManageListingEmptyPhotos extends StatelessWidget {
  const ManageListingEmptyPhotos({super.key});

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
            Icon(Icons.photo_library_outlined, size: 48, color: AppTheme.gray),
            SizedBox(height: 12),
            Text(
              'No photos yet',
              style: TextStyle(
                color: AppTheme.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tap Add Photos to upload',
              style: TextStyle(color: AppTheme.gray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

