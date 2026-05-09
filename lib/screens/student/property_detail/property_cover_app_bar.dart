import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/property.dart';
import 'package:student_nest/core/theme/app_colors.dart';

class PropertyCoverAppBar extends StatelessWidget {
  final Photo? coverPhoto;

  const PropertyCoverAppBar({super.key, required this.coverPhoto});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppDesign.accent,
      flexibleSpace: FlexibleSpaceBar(
        background:
            coverPhoto != null
                ? CachedNetworkImage(
                  imageUrl: coverPhoto!.cacheAwareUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (_, __) => Container(
                        color: AppDesign.accentTint(context),
                      ),
                  errorWidget: (_, __, ___) => _fallback(context),
                )
                : _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: AppDesign.accentTint(context),
      child: const Icon(
        Icons.home_work_outlined,
        size: 64,
        color: AppDesign.accent,
      ),
    );
  }
}
