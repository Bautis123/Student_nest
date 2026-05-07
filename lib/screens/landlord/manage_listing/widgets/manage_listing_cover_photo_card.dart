import 'package:flutter/material.dart';

import '../../../../models/property.dart';
import '../../../../utils/app_design.dart';
import '../../../../utils/theme.dart';

class ManageListingCoverPhotoCard extends StatelessWidget {
  final Photo? coverPhoto;
  final VoidCallback onAddTap;
  final VoidCallback? onDeleteTap;

  const ManageListingCoverPhotoCard({
    super.key,
    required this.coverPhoto,
    required this.onAddTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (coverPhoto == null) {
      return GestureDetector(
        onTap: onAddTap,
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppDesign.accent.withValues(alpha: 0.34)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: AppDesign.accent,
                size: 40,
              ),
              SizedBox(height: 8),
              Text(
                'Tap to add cover photo',
                style: TextStyle(color: AppDesign.accent, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            coverPhoto!.url,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppDesign.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'Cover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: onDeleteTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
