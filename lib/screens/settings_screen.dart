import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/theme/app_theme.dart';
import 'landlord/choose_plan/choose_plan_screen.dart';
import 'landlord/dashboard_screen.dart';
import 'landlord/login_screen.dart';
import 'main_screen.dart';
import 'settings/settings_bottom_sheet.dart';
import 'settings/settings_content.dart';
import 'settings/settings_logout_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onOpenSaved,
    this.onOpenHome,
    this.onOpenLandlordListings,
  });

  final VoidCallback? onOpenSaved;
  final VoidCallback? onOpenHome;
  final VoidCallback? onOpenLandlordListings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _preferredSchoolIdKey = 'preferred_school_id';
  static const String _preferredSchoolNameKey = 'preferred_school_name';
  static const String _notificationsKey = 'notifications_enabled';

  final ApiService _api = ApiService();
  User? _user;
  List<Map<String, dynamic>> _schools = [];
  String _preferredSchoolLabel = 'University of Zambia';
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadNotificationPreference();
    _loadPreferredSchool();
    _loadSchools();
  }

  Future<void> _loadUser() async {
    final user = await _api.getUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _loadPreferredSchool() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _preferredSchoolLabel =
          prefs.getString(_preferredSchoolNameKey) ?? 'University of Zambia';
    });
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifications = prefs.getBool(_notificationsKey) ?? true;
    });
  }

  Future<void> _updateNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    if (!mounted) return;
    setState(() => _notifications = value);
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await _api.getSchools();
      if (!mounted) return;
      setState(() => _schools = schools);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _schools = const [
          {
            'id': 'unza',
            'name': 'University of Zambia',
            'area': 'Great East Road',
          },
        ];
      });
    }
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

  void _openLandlordListings() {
    if (widget.onOpenLandlordListings != null) {
      widget.onOpenLandlordListings!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(listingsOnly: true),
      ),
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

  void _openProfileSheet() {
    _showSettingsSheet(
      title: 'Profile',
      icon: Icons.person_outline_rounded,
      children: [
        SettingsDetailRow(label: 'Name', value: _user?.fullName ?? 'Guest'),
        SettingsDetailRow(
          label: 'Status',
          value: _user == null ? 'Not logged in' : 'Logged in',
        ),
        if (_user != null) ...[
          SettingsDetailRow(label: 'Phone', value: _user!.phone),
          SettingsDetailRow(
            label: 'Email',
            value: _user!.email ?? 'Not added',
          ),
          SettingsDetailRow(label: 'Role', value: _formatRole(_user!.role)),
          SettingsDetailRow(
            label: 'Approval',
            value: _user!.isApproved ? 'Approved' : 'Pending',
          ),
        ],
        const SizedBox(height: 10),
        Text(
          _user == null
              ? 'Create or log into a landlord account to manage listings.'
              : 'Profile editing is limited for account security. Contact support for changes to locked details.',
          style: TextStyle(
            color: AppDesign.muted(context),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        if (_user == null) ...[
          const SizedBox(height: 16),
          SheetPrimaryButton(
            label: 'Landlord Login',
            onTap: () {
              Navigator.pop(context);
              _openLandlordLogin();
            },
          ),
        ],
      ],
    );
  }

  void _openLanguageSheet() {
    _showSettingsSheet(
      title: 'Language',
      icon: Icons.language_outlined,
      children: const [
        SettingsChoiceRow(
          title: 'English',
          subtitle: 'Current app language',
          selected: true,
        ),
        SizedBox(height: 8),
        SettingsChoiceRow(
          title: 'More languages',
          subtitle: 'Coming soon',
          selected: false,
        ),
      ],
    );
  }

  Future<void> _openPreferredSchoolSheet() async {
    if (_schools.isEmpty) await _loadSchools();
    if (!mounted) return;

    _showSettingsSheet(
      title: 'Preferred School',
      icon: Icons.school_outlined,
      children: [
        Text(
          'Choose the school shown as your default preference in Student Nest.',
          style: TextStyle(
            color: AppDesign.muted(context),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        for (final school in _schools)
          SettingsActionRow(
            title: school['name']?.toString() ?? 'School',
            subtitle: school['area']?.toString() ?? 'Nearby boarding houses',
            trailing:
                _preferredSchoolLabel == school['name']?.toString()
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
            onTap: () => _savePreferredSchool(school),
          ),
      ],
    );
  }

  Future<void> _savePreferredSchool(Map<String, dynamic> school) async {
    final prefs = await SharedPreferences.getInstance();
    final id = school['id']?.toString();
    final name = school['name']?.toString() ?? 'School';
    if (id != null) await prefs.setString(_preferredSchoolIdKey, id);
    await prefs.setString(_preferredSchoolNameKey, name);
    if (!mounted) return;
    setState(() => _preferredSchoolLabel = name);
    Navigator.pop(context);
    widget.onOpenHome?.call();
  }

  void _openSaved() {
    if (widget.onOpenSaved != null) {
      widget.onOpenSaved!();
      return;
    }
    _showSettingsSheet(
      title: 'Saved Boarding Houses',
      icon: Icons.bookmark_border_rounded,
      children: [
        Text(
          'Saved listings are available from the Saved tab in the student app.',
          style: TextStyle(color: AppDesign.muted(context), fontSize: 13),
        ),
      ],
    );
  }

  void _openSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChoosePlanScreen()),
    );
  }

  void _openHelpCenter() {
    _showSettingsSheet(
      title: 'Help Center',
      icon: Icons.help_outline_rounded,
      children: const [
        SettingsFaqItem(
          question: 'How do I save a boarding house?',
          answer: 'Tap the bookmark icon on any listing card.',
        ),
        SettingsFaqItem(
          question: 'How do I filter by school?',
          answer: 'Use the school selector on the Browse screen.',
        ),
        SettingsFaqItem(
          question: 'How do landlords list properties?',
          answer:
              'Use Landlord Login, then add and manage listings from the dashboard.',
        ),
      ],
    );
  }

  void _openContactSupport() {
    _showSettingsSheet(
      title: 'Contact Support',
      icon: Icons.support_agent_rounded,
      children: [
        SettingsActionRow(
          title: 'Email support',
          subtitle: 'support@studentnest.app',
          trailing: Icons.open_in_new_rounded,
          onTap:
              () => _launchSupportUri(
                Uri(
                  scheme: 'mailto',
                  path: 'support@studentnest.app',
                  queryParameters: {'subject': 'Student Nest Support'},
                ),
              ),
        ),
        SettingsActionRow(
          title: 'Call support',
          subtitle: '+260 970 000 000',
          trailing: Icons.call_outlined,
          onTap:
              () =>
                  _launchSupportUri(Uri(scheme: 'tel', path: '+260970000000')),
        ),
      ],
    );
  }

  Future<void> _launchSupportUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open support action.')),
    );
  }

  void _openAdminDashboard() {
    _showSettingsSheet(
      title: 'Admin Dashboard',
      icon: Icons.admin_panel_settings_outlined,
      children: [
        Text(
          'Admin management is available in the Student Nest web admin panel.',
          style: TextStyle(
            color: AppDesign.muted(context),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  void _openPrivacyPolicy() {
    _showLegalSheet(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      paragraphs: const [
        'Student Nest uses account, listing, and saved preference data to help students discover suitable boarding houses.',
        'Location and school preferences are used to improve search and filtering. They are not shown publicly as personal student data.',
        'Contact and account details are handled for authentication, support, and landlord listing management.',
      ],
    );
  }

  void _openTerms() {
    _showLegalSheet(
      title: 'Terms of Service',
      icon: Icons.description_outlined,
      paragraphs: const [
        'Students should verify listings, rooms, payments, and landlord identity before committing to a boarding house.',
        'Landlords are responsible for submitting accurate listing, room, pricing, and contact information.',
        'Student Nest may review, approve, reject, or remove listings to protect users and platform quality.',
      ],
    );
  }

  void _showLegalSheet({
    required String title,
    required IconData icon,
    required List<String> paragraphs,
  }) {
    _showSettingsSheet(
      title: title,
      icon: icon,
      children: paragraphs
          .map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                paragraph,
                style: TextStyle(
                  color: AppDesign.muted(context),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  void _showSettingsSheet({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => SettingsBottomSheet(
            title: title,
            icon: icon,
            children: children,
          ),
    );
  }

  static String _formatRole(String role) {
    if (role.isEmpty) return 'User';
    return role[0].toUpperCase() + role.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final themeController = AppThemeScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppDesign.page(context),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppDesign.text(context),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppDesign.surface(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SettingsContent(
        user: _user,
        theme: theme,
        themeController: themeController,
        notificationsEnabled: _notifications,
        preferredSchoolLabel: _preferredSchoolLabel,
        onOpenProfile: _openProfileSheet,
        onOpenLanguage: _openLanguageSheet,
        onNotificationsChanged: _updateNotifications,
        onOpenAdminDashboard: _openAdminDashboard,
        onOpenSaved: _openSaved,
        onOpenPreferredSchool: _openPreferredSchoolSheet,
        onOpenLandlordListings: _openLandlordListings,
        onOpenListingStatistics: _openLandlordDashboard,
        onOpenSubscription: _openSubscription,
        onOpenHelpCenter: _openHelpCenter,
        onContactSupport: _openContactSupport,
        onOpenPrivacyPolicy: _openPrivacyPolicy,
        onOpenTerms: _openTerms,
        onOpenLandlordLogin: _openLandlordLogin,
        onShowLogoutDialog: _showLogoutDialog,
      ),
    );
  }
}
