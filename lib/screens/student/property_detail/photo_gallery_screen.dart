import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
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
                imageUrl: photos[i].url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[900]),
                errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
              ),
            ),
      ),
    );
  }
}
