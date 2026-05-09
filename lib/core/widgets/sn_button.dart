import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

enum SNButtonVariant { primary, outlined, ghost, danger }

class SNButton extends StatelessWidget {
  const SNButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SNButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.leadingIcon,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final SNButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? leadingIcon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    final child = _SNButtonContent(
      label: label,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      foregroundColor: colors.foreground,
    );

    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        Size(fullWidth ? double.infinity : 0, height),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled)
                ? colors.background.withValues(alpha: 0.55)
                : colors.background,
      ),
      foregroundColor: WidgetStateProperty.all(colors.foreground),
      side: WidgetStateProperty.all(BorderSide(color: colors.border)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );
  }

  _SNButtonColors _colors(BuildContext context) {
    switch (variant) {
      case SNButtonVariant.primary:
        return const _SNButtonColors(
          background: AppColors.primary,
          foreground: AppColors.white,
          border: AppColors.primary,
        );
      case SNButtonVariant.outlined:
        return const _SNButtonColors(
          background: Colors.transparent,
          foreground: AppColors.primary,
          border: AppColors.primary,
        );
      case SNButtonVariant.ghost:
        return const _SNButtonColors(
          background: Colors.transparent,
          foreground: AppColors.textSecondary,
          border: Colors.transparent,
        );
      case SNButtonVariant.danger:
        return const _SNButtonColors(
          background: AppColors.error,
          foreground: AppColors.white,
          border: AppColors.error,
        );
    }
  }
}

class _SNButtonContent extends StatelessWidget {
  const _SNButtonContent({
    required this.label,
    required this.isLoading,
    required this.leadingIcon,
    required this.foregroundColor,
  });

  final String label;
  final bool isLoading;
  final IconData? leadingIcon;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: foregroundColor,
          strokeWidth: 2,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _SNButtonColors {
  const _SNButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
