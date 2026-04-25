import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../utils/student_nest_icons.dart';
import '../../utils/theme.dart';
import 'settings_switch_tile.dart';
import 'settings_tile.dart';

class SettingsTileGroups {
  static List<Widget> general({
    required AppThemeController themeController,
    required bool isDarkMode,
    required bool notificationsEnabled,
    required ValueChanged<bool> onNotificationsChanged,
  }) {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.profile,
        iconColor: const Color(0xFF6366F1),
        title: 'Profile',
        subtitle: 'Edit your personal information',
        onTap: () {},
      ),
      SettingsSwitchTile(
        assetIcon: StudentNestIcons.notifications,
        iconColor: const Color(0xFFF59E0B),
        title: 'Notifications',
        subtitle: 'Receive listing alerts',
        value: notificationsEnabled,
        onChanged: onNotificationsChanged,
      ),
      SettingsSwitchTile(
        icon: Icons.dark_mode_outlined,
        iconColor: const Color(0xFF1E293B),
        title: 'Dark Mode',
        subtitle: 'Switch app appearance',
        value: isDarkMode,
        onChanged: (value) {
          themeController.updateThemeMode(
            value ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
      SettingsTile(
        icon: Icons.language_outlined,
        iconColor: const Color(0xFF10B981),
        title: 'Language',
        subtitle: 'English',
        onTap: () {},
      ),
    ];
  }

  static List<Widget> student() {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.save,
        iconColor: const Color(0xFFEF4444),
        title: 'Saved Boarding Houses',
        subtitle: 'Your saved listings',
        onTap: () {},
      ),
      SettingsTile(
        assetIcon: StudentNestIcons.university,
        iconColor: const Color(0xFF3B82F6),
        title: 'Preferred School',
        subtitle: 'University of Zambia',
        onTap: () {},
      ),
    ];
  }

  static List<Widget> landlord({
    required VoidCallback onOpenLandlordDashboard,
  }) {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.building,
        iconColor: const Color(0xFF1A56DB),
        title: 'My Boarding Houses',
        subtitle: 'Manage your listings',
        onTap: onOpenLandlordDashboard,
      ),
      SettingsTile(
        icon: Icons.bar_chart_outlined,
        iconColor: const Color(0xFF10B981),
        title: 'Listing Statistics',
        subtitle: 'Views and contact clicks',
        onTap: onOpenLandlordDashboard,
      ),
      SettingsTile(
        assetIcon: StudentNestIcons.payment,
        iconColor: const Color(0xFFF59E0B),
        title: 'Subscription',
        subtitle: 'Manage your listing plan',
        onTap: () {},
      ),
    ];
  }

  static List<Widget> admin() {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.safety,
        iconColor: const Color(0xFF7C3AED),
        title: 'Admin Dashboard',
        subtitle: 'Manage the platform',
        onTap: () {},
      ),
    ];
  }

  static List<Widget> support() {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.support,
        iconColor: const Color(0xFF0284C7),
        title: 'Help Center',
        subtitle: 'FAQs and guides',
        onTap: () {},
      ),
      SettingsTile(
        assetIcon: StudentNestIcons.chat,
        iconColor: const Color(0xFF10B981),
        title: 'Contact Support',
        subtitle: 'Get help from our team',
        onTap: () {},
      ),
    ];
  }

  static List<Widget> legal() {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.safety,
        iconColor: const Color(0xFF64748B),
        title: 'Privacy Policy',
        onTap: () {},
      ),
      SettingsTile(
        assetIcon: StudentNestIcons.lease,
        iconColor: const Color(0xFF64748B),
        title: 'Terms of Service',
        onTap: () {},
      ),
    ];
  }

  static List<Widget> account({
    required User? user,
    required VoidCallback onOpenLandlordLogin,
    required VoidCallback onShowLogoutDialog,
  }) {
    if (user == null) {
      return [
        SettingsTile(
          icon: Icons.login_outlined,
          iconColor: AppTheme.primary,
          title: 'Landlord Login',
          subtitle: 'List your property',
          onTap: onOpenLandlordLogin,
        ),
      ];
    }

    return [
      SettingsTile(
        icon: Icons.logout_outlined,
        iconColor: AppTheme.error,
        title: 'Log Out',
        titleColor: AppTheme.error,
        onTap: onShowLogoutDialog,
      ),
    ];
  }
}
