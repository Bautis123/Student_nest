import 'package:flutter/material.dart';

import '../../models/user.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import '../../utils/student_nest_icons.dart';
import 'package:student_nest/core/theme/app_theme.dart';
import 'settings_switch_tile.dart';
import 'settings_tile.dart';

class SettingsTileGroups {
  static List<Widget> general({
    required AppThemeController themeController,
    required bool isDarkMode,
    required bool notificationsEnabled,
    required ValueChanged<bool> onNotificationsChanged,
    required VoidCallback onOpenProfile,
    required VoidCallback onOpenLanguage,
  }) {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.profile,
        iconColor: AppDesign.accent,
        title: 'Profile',
        subtitle: 'Edit your personal information',
        onTap: onOpenProfile,
      ),
      SettingsSwitchTile(
        assetIcon: StudentNestIcons.notifications,
        iconColor: AppDesign.accent,
        title: 'Notifications',
        subtitle: 'Receive listing alerts',
        value: notificationsEnabled,
        onChanged: onNotificationsChanged,
      ),
      SettingsSwitchTile(
        icon: Icons.dark_mode_outlined,
        iconColor: AppDesign.lightMuted,
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
        iconColor: AppDesign.accent,
        title: 'Language',
        subtitle: 'English',
        onTap: onOpenLanguage,
      ),
    ];
  }

  static List<Widget> student({
    required VoidCallback onOpenSaved,
    required VoidCallback onOpenPreferredSchool,
    required String preferredSchoolLabel,
  }) {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.save,
        iconColor: AppDesign.accent,
        title: 'Saved Boarding Houses',
        subtitle: 'Your saved listings',
        onTap: onOpenSaved,
      ),
      SettingsTile(
        assetIcon: StudentNestIcons.university,
        iconColor: AppDesign.accent,
        title: 'Preferred School',
        subtitle: preferredSchoolLabel,
        onTap: onOpenPreferredSchool,
      ),
    ];
  }

  static List<Widget> landlord({
    required VoidCallback onOpenLandlordListings,
    required VoidCallback onOpenListingStatistics,
    required VoidCallback onOpenSubscription,
  }) {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.building,
        iconColor: AppDesign.accent,
        title: 'My Boarding Houses',
        subtitle: 'Manage your listings',
        onTap: onOpenLandlordListings,
      ),
      SettingsTile(
        icon: Icons.bar_chart_outlined,
        iconColor: AppDesign.accent,
        title: 'Listing Statistics',
        subtitle: 'Views and contact clicks',
        onTap: onOpenListingStatistics,
      ),
      SettingsTile(
        assetIcon: StudentNestIcons.payment,
        iconColor: AppDesign.accent,
        title: 'Subscription',
        subtitle: 'Manage your listing plan',
        onTap: onOpenSubscription,
      ),
    ];
  }

  static List<Widget> admin({required VoidCallback onOpenAdminDashboard}) {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.safety,
        iconColor: AppColors.primaryDark,
        title: 'Admin Dashboard',
        subtitle: 'Manage the platform',
        onTap: onOpenAdminDashboard,
      ),
    ];
  }

  static List<Widget> support({
    required VoidCallback onOpenHelpCenter,
    required VoidCallback onContactSupport,
  }) {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.support,
        iconColor: AppColors.primaryDark,
        title: 'Help Center',
        subtitle: 'FAQs and guides',
        onTap: onOpenHelpCenter,
      ),
      SettingsTile(
        assetIcon: StudentNestIcons.chat,
        iconColor: AppColors.primary,
        title: 'Contact Support',
        subtitle: 'Get help from our team',
        onTap: onContactSupport,
      ),
    ];
  }

  static List<Widget> legal({
    required VoidCallback onOpenPrivacyPolicy,
    required VoidCallback onOpenTerms,
  }) {
    return [
      SettingsTile(
        assetIcon: StudentNestIcons.safety,
        iconColor: AppColors.textSecondary,
        title: 'Privacy Policy',
        onTap: onOpenPrivacyPolicy,
      ),
      SettingsTile(
        assetIcon: StudentNestIcons.lease,
        iconColor: AppColors.textSecondary,
        title: 'Terms of Service',
        onTap: onOpenTerms,
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
          iconColor: AppDesign.accent,
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
