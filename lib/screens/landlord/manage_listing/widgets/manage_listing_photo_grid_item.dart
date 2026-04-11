import 'package:flutter/material.dart';

import '../../../../models/property.dart';
import '../../../../utils/theme.dart';

class ManageListingPhotoGridItem extends StatelessWidget {
  final Photo photo;
  final VoidCallback onTap;
  final VoidCallback onDeleteTap;

  const ManageListingPhotoGridItem({
    super.key,
    required this.photo,
    required this.onTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photo.url,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Set as cover',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onDeleteTap,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
