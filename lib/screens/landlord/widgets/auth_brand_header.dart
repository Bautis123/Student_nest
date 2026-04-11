import 'package:flutter/material.dart';

import '../../../utils/theme.dart';

class AuthBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;
  final String? portalLabel;

  const AuthBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = false,
    this.portalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLogo)
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.home_work_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Student Nest',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (portalLabel != null)
                  Text(
                    portalLabel!,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  ),
              ],
            ),
          ),
        if (showLogo) const SizedBox(height: 40),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
      ],
    );
  }
}
