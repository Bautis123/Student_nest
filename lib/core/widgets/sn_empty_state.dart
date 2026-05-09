import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'sn_button.dart';

class SNEmptyState extends StatelessWidget {
  const SNEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCtaPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: 16),
              SNButton(
                label: ctaLabel!,
                onPressed: onCtaPressed,
                fullWidth: false,
                height: 44,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
