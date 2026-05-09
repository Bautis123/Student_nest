import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SNLoadingIndicator extends StatelessWidget {
  const SNLoadingIndicator({super.key, this.centered = true});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    const indicator = CircularProgressIndicator(color: AppColors.primary);
    return centered ? const Center(child: indicator) : indicator;
  }
}
