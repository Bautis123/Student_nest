import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'full_screen_photo.dart';

class PhotoGalleryScreen extends StatelessWidget {
  final List<dynamic> photos;
  final String title;

  const PhotoGalleryScreen({
    super.key,
    required this.photos,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.white, fontSize: 16),
        ),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: photos.length,
        itemBuilder:
            (_, i) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => FullScreenPhoto(photos: photos, initialIndex: i),
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: photos[i].cacheAwareUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.navy),
                errorWidget: (_, __, ___) => Container(color: AppColors.navy),
              ),
            ),
      ),
    );
  }
}
