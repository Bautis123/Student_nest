import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.navy.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
