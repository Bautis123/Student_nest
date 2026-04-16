import 'package:flutter/material.dart';

import '../utils/theme.dart';

class AppHeaderBackground extends StatelessWidget {
  const AppHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.lightGray,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withValues(alpha: 0.28),
              AppTheme.primaryLight.withValues(alpha: 0.60),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -120,
              right: -72,
              child: _Blob(
                size: 260,
                color: AppTheme.primary.withValues(alpha: 0.40),
              ),
            ),
            Positioned(
              top: 22,
              left: -70,
              child: _Blob(
                size: 190,
                color: AppTheme.primary.withValues(alpha: 0.32),
              ),
            ),
            Positioned(
              top: 58,
              right: 68,
              child: _Blob(
                size: 120,
                color: AppTheme.accent.withValues(alpha: 0.30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
