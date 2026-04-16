import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../widgets/app_header_background.dart';
import 'landlord/dashboard_screen.dart';
import 'landlord/login_screen.dart';
import 'main_screen.dart';
import 'settings/settings_profile_header.dart';
import 'settings/settings_section.dart';
import 'settings/settings_logout_dialog.dart';
import 'settings/settings_tile_groups.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _api = ApiService();
  User? _user;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _api.getUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _logout() async {
    await _api.logout();
    if (!mounted) return;
    setState(() => _user = null);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  void _openLandlordDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _openLandlordLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    ).then((_) => _loadUser());
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => SettingsLogoutDialog(onConfirm: _logout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = AppThemeScope.of(context);
    final theme = Theme.of(context);
    final isDarkMode = themeController.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: const AppHeaderBackground(),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          SettingsProfileHeader(user: _user),
          SettingsSection(
            title: 'Settings',
            tiles: SettingsTileGroups.general(
              themeController: themeController,
              isDarkMode: isDarkMode,
              notificationsEnabled: _notifications,
              onNotificationsChanged: (v) {
                setState(() => _notifications = v);
              },
            ),
          ),
          if (_user == null || _user?.role == 'student')
            SettingsSection(
              title: 'Student Options',
              tiles: SettingsTileGroups.student(),
            ),
          if (_user?.role == 'landlord')
            SettingsSection(
              title: 'Landlord Options',
              tiles: SettingsTileGroups.landlord(
                onOpenLandlordDashboard: _openLandlordDashboard,
              ),
            ),
          if (_user?.role == 'admin')
            SettingsSection(
              title: 'Admin Options',
              tiles: SettingsTileGroups.admin(),
            ),
          SettingsSection(
            title: 'Support',
            tiles: SettingsTileGroups.support(),
          ),
          SettingsSection(title: 'Legal', tiles: SettingsTileGroups.legal()),
          SettingsSection(
            title: 'Account',
            tiles: SettingsTileGroups.account(
              user: _user,
              onOpenLandlordLogin: _openLandlordLogin,
              onShowLogoutDialog: _showLogoutDialog,
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
      ),
    );
  }
}
