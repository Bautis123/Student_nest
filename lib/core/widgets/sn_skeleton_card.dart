import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class SNSkeletonCard extends StatefulWidget {
  const SNSkeletonCard({super.key, this.height = 140});

  final double height;

  @override
  State<SNSkeletonCard> createState() => _SNSkeletonCardState();
}

class _SNSkeletonCardState extends State<SNSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}
