import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF1B9E6E);
  static const Color primaryDark = Color(0xFF15795A);
  static const Color primaryLight = Color(0xFF25C98C);
  static const Color primaryTint = Color(0xFFE8F7F2);
  static const Color navy = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFFF5F7FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFDDE1E8);
  static const Color divider = Color(0xFFEBEEF3);
  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF5A6472);
  static const Color textHint = Color(0xFF9BA3AE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningTint = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorTint = Color(0xFFFEE2E2);
  static const Color success = primary;
  static const Color successTint = primaryTint;
}

class AppDesign {
  const AppDesign._();

  static const Color accent = AppColors.primary;
  static const Color lightPage = AppColors.surface;
  static const Color lightSurface = AppColors.white;
  static const Color lightText = AppColors.textPrimary;
  static const Color lightMuted = AppColors.textSecondary;
  static const Color lightSubtle = AppColors.textHint;
  static const Color lightBorder = AppColors.border;
  static const Color lightAccentTint = AppColors.primaryTint;

  static const Color darkPage = Color(0xFF11161C);
  static const Color darkSurface = Color(0xFF171E26);
  static const Color darkText = AppColors.white;
  static const Color darkMuted = Color(0xFFA0ADBA);
  static const Color darkBorder = Color(0xFF2A3440);
  static const Color darkAccentTint = Color(0xFF20352E);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color page(BuildContext context) =>
      isDark(context) ? darkPage : AppColors.surface;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : AppColors.white;

  static Color text(BuildContext context) =>
      isDark(context) ? darkText : AppColors.textPrimary;

  static Color muted(BuildContext context) =>
      isDark(context) ? darkMuted : AppColors.textSecondary;

  static Color subtle(BuildContext context) =>
      isDark(context) ? darkMuted : AppColors.textHint;

  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : AppColors.border;

  static Color accentTint(BuildContext context) =>
      isDark(context) ? darkAccentTint : AppColors.primaryTint;

  static Color shadow(BuildContext context) =>
      AppColors.navy.withValues(alpha: isDark(context) ? 0.18 : 0.06);

  static List<BoxShadow> softShadow(BuildContext context) => [
    BoxShadow(
      color: shadow(context),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static BoxDecoration surfaceDecoration(
    BuildContext context, {
    double radius = 8,
    bool shadow = true,
    Color? color,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? surface(context),
      borderRadius: BorderRadius.circular(radius),
      border: border ?? Border.all(color: AppDesign.border(context)),
      boxShadow: shadow ? softShadow(context) : null,
    );
  }
}
