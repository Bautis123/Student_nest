import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/property.dart';
import 'package:student_nest/core/theme/app_theme.dart';

class PropertyCoverAppBar extends StatelessWidget {
  final Photo? coverPhoto;

  const PropertyCoverAppBar({super.key, required this.coverPhoto});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background:
            coverPhoto != null
                ? CachedNetworkImage(
                  imageUrl: coverPhoto!.url,
                  fit: BoxFit.cover,
                  placeholder:
                      (_, __) => Container(color: AppTheme.primaryLight),
                  errorWidget: (_, __, ___) => _fallback(),
                )
                : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppTheme.primaryLight,
      child: const Icon(
        Icons.home_work_outlined,
        size: 64,
        color: AppTheme.primary,
      ),
    );
  }
}
