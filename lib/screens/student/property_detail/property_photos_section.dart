import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/property.dart';
import 'package:student_nest/core/theme/app_colors.dart';

class PropertyPhotosSection extends StatelessWidget {
  final List<Photo> photos;
  final VoidCallback onViewAll;

  const PropertyPhotosSection({
    super.key,
    required this.photos,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppDesign.text(context),
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View all ${photos.length} photos',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppDesign.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length > 4 ? 4 : photos.length,
            itemBuilder: (_, i) {
              final isLast = i == 3 && photos.length > 4;
              return GestureDetector(
                onTap: onViewAll,
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: photos[i].cacheAwareUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (isLast)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: AppColors.navy.withValues(alpha: 0.5),
                            child: Center(
                              child: Text(
                                '+${photos.length - 3}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
