import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_theme.dart';

import '../../models/user.dart';
import 'settings_profile_header.dart';
import 'settings_section.dart';
import 'settings_tile_groups.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({
    super.key,
    required this.user,
    required this.theme,
    required this.themeController,
    required this.notificationsEnabled,
    required this.preferredSchoolLabel,
    required this.onOpenProfile,
    required this.onOpenLanguage,
    required this.onNotificationsChanged,
    required this.onOpenAdminDashboard,
    required this.onOpenSaved,
    required this.onOpenPreferredSchool,
    required this.onOpenLandlordListings,
    required this.onOpenListingStatistics,
    required this.onOpenSubscription,
    required this.onOpenHelpCenter,
    required this.onContactSupport,
    required this.onOpenPrivacyPolicy,
    required this.onOpenTerms,
    required this.onOpenLandlordLogin,
    required this.onShowLogoutDialog,
  });

  final User? user;
  final ThemeData theme;
  final AppThemeController themeController;
  final bool notificationsEnabled;
  final String preferredSchoolLabel;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenLanguage;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onOpenAdminDashboard;
  final VoidCallback onOpenSaved;
  final VoidCallback onOpenPreferredSchool;
  final VoidCallback onOpenLandlordListings;
  final VoidCallback onOpenListingStatistics;
  final VoidCallback onOpenSubscription;
  final VoidCallback onOpenHelpCenter;
  final VoidCallback onContactSupport;
  final VoidCallback onOpenPrivacyPolicy;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenLandlordLogin;
  final VoidCallback onShowLogoutDialog;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeController.isDarkMode;

    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: [
        SettingsProfileHeader(user: user),
        SettingsSection(
          title: 'Settings',
          tiles: SettingsTileGroups.general(
            themeController: themeController,
            isDarkMode: isDarkMode,
            notificationsEnabled: notificationsEnabled,
            onOpenProfile: onOpenProfile,
            onOpenLanguage: onOpenLanguage,
            onNotificationsChanged: onNotificationsChanged,
          ),
        ),
        if (user?.role == 'admin')
          SettingsSection(
            title: 'Admin',
            tiles: SettingsTileGroups.admin(
              onOpenAdminDashboard: onOpenAdminDashboard,
            ),
          ),
        if (user == null || user?.role == 'student')
          SettingsSection(
            title: 'Student Options',
            tiles: SettingsTileGroups.student(
              onOpenSaved: onOpenSaved,
              onOpenPreferredSchool: onOpenPreferredSchool,
              preferredSchoolLabel: preferredSchoolLabel,
            ),
          ),
        if (user?.role == 'landlord')
          SettingsSection(
            title: 'Landlord Options',
            tiles: SettingsTileGroups.landlord(
              onOpenLandlordListings: onOpenLandlordListings,
              onOpenListingStatistics: onOpenListingStatistics,
              onOpenSubscription: onOpenSubscription,
            ),
          ),
        SettingsSection(
          title: 'Support',
          tiles: SettingsTileGroups.support(
            onOpenHelpCenter: onOpenHelpCenter,
            onContactSupport: onContactSupport,
          ),
        ),
        SettingsSection(
          title: 'Legal',
          tiles: SettingsTileGroups.legal(
            onOpenPrivacyPolicy: onOpenPrivacyPolicy,
            onOpenTerms: onOpenTerms,
          ),
        ),
        SettingsSection(
          title: 'Account',
          tiles: SettingsTileGroups.account(
            user: user,
            onOpenLandlordLogin: onOpenLandlordLogin,
            onShowLogoutDialog: onShowLogoutDialog,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Student Nest v1.0.0\nBautis Digital Innovations Ltd',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
