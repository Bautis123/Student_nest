import 'package:flutter/material.dart';

class AppDesign {
  const AppDesign._();

  static const Color accent = Color(0xFF1B9E6E);
  static const Color lightPage = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF111827);
  static const Color lightMuted = Color(0xFF6E7782);
  static const Color lightSubtle = Color(0xFF98A2B3);
  static const Color lightBorder = Color(0xFFE2E6EE);
  static const Color lightAccentTint = Color(0xFFEAF6F1);

  static const Color darkPage = Color(0xFF11161C);
  static const Color darkSurface = Color(0xFF171E26);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkMuted = Color(0xFFA0ADBA);
  static const Color darkBorder = Color(0xFF2A3440);
  static const Color darkAccentTint = Color(0xFF20352E);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color page(BuildContext context) => isDark(context) ? darkPage : lightPage;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color text(BuildContext context) => isDark(context) ? darkText : lightText;

  static Color muted(BuildContext context) =>
      isDark(context) ? darkMuted : lightMuted;

  static Color subtle(BuildContext context) =>
      isDark(context) ? darkMuted : lightSubtle;

  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color accentTint(BuildContext context) =>
      isDark(context) ? darkAccentTint : lightAccentTint;

  static Color shadow(BuildContext context) =>
      Colors.black.withValues(alpha: isDark(context) ? 0.18 : 0.06);

  static List<BoxShadow> softShadow(BuildContext context) => [
    BoxShadow(
      color: shadow(context),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static BoxDecoration surfaceDecoration(
    BuildContext context, {
    double radius = 24,
    bool shadow = true,
    Color? color,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? surface(context),
      borderRadius: BorderRadius.circular(radius),
      border: border,
      boxShadow: shadow ? softShadow(context) : null,
    );
  }
}
