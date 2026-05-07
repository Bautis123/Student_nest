import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/app_design.dart';
import '../utils/theme.dart';
import 'landlord/choose_plan/choose_plan_screen.dart';
import 'landlord/dashboard_screen.dart';
import 'landlord/login_screen.dart';
import 'main_screen.dart';
import 'settings/settings_profile_header.dart';
import 'settings/settings_section.dart';
import 'settings/settings_logout_dialog.dart';
import 'settings/settings_tile_groups.dart';

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
          {'id': 'unza', 'name': 'University of Zambia', 'area': 'Great East Road'},
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
      MaterialPageRoute(builder: (_) => const DashboardScreen(listingsOnly: true)),
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
        _SettingsDetailRow(label: 'Name', value: _user?.fullName ?? 'Guest'),
        _SettingsDetailRow(
          label: 'Status',
          value: _user == null ? 'Not logged in' : 'Logged in',
        ),
        if (_user != null) ...[
          _SettingsDetailRow(label: 'Phone', value: _user!.phone),
          _SettingsDetailRow(label: 'Email', value: _user!.email ?? 'Not added'),
          _SettingsDetailRow(label: 'Role', value: _formatRole(_user!.role)),
          _SettingsDetailRow(
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
          _SheetPrimaryButton(
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
        _SettingsChoiceRow(
          title: 'English',
          subtitle: 'Current app language',
          selected: true,
        ),
        SizedBox(height: 8),
        _SettingsChoiceRow(
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
          _SettingsActionRow(
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
        _SettingsFaqItem(
          question: 'How do I save a boarding house?',
          answer: 'Tap the bookmark icon on any listing card.',
        ),
        _SettingsFaqItem(
          question: 'How do I filter by school?',
          answer: 'Use the school selector on the Browse screen.',
        ),
        _SettingsFaqItem(
          question: 'How do landlords list properties?',
          answer: 'Use Landlord Login, then add and manage listings from the dashboard.',
        ),
      ],
    );
  }

  void _openContactSupport() {
    _showSettingsSheet(
      title: 'Contact Support',
      icon: Icons.support_agent_rounded,
      children: [
        _SettingsActionRow(
          title: 'Email support',
          subtitle: 'support@studentnest.app',
          trailing: Icons.open_in_new_rounded,
          onTap: () => _launchSupportUri(
            Uri(
              scheme: 'mailto',
              path: 'support@studentnest.app',
              queryParameters: {'subject': 'Student Nest Support'},
            ),
          ),
        ),
        _SettingsActionRow(
          title: 'Call support',
          subtitle: '+260 970 000 000',
          trailing: Icons.call_outlined,
          onTap: () => _launchSupportUri(Uri(scheme: 'tel', path: '+260970000000')),
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
      children:
          paragraphs
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
      builder: (_) => _SettingsBottomSheet(
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
    final isDarkMode = themeController.isDarkMode;

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
      body: ListView(
        padding: const EdgeInsets.only(bottom: 18),
        children: [
          SettingsProfileHeader(user: _user),
          SettingsSection(
            title: 'Settings',
            tiles: SettingsTileGroups.general(
              themeController: themeController,
              isDarkMode: isDarkMode,
              notificationsEnabled: _notifications,
              onOpenProfile: _openProfileSheet,
              onOpenLanguage: _openLanguageSheet,
              onNotificationsChanged: _updateNotifications,
            ),
          ),
          if (_user?.role == 'admin')
            SettingsSection(
              title: 'Admin',
              tiles: SettingsTileGroups.admin(
                onOpenAdminDashboard: _openAdminDashboard,
              ),
            ),
          if (_user == null || _user?.role == 'student')
            SettingsSection(
              title: 'Student Options',
              tiles: SettingsTileGroups.student(
                onOpenSaved: _openSaved,
                onOpenPreferredSchool: _openPreferredSchoolSheet,
                preferredSchoolLabel: _preferredSchoolLabel,
              ),
            ),
          if (_user?.role == 'landlord')
            SettingsSection(
              title: 'Landlord Options',
              tiles: SettingsTileGroups.landlord(
                onOpenLandlordListings: _openLandlordListings,
                onOpenListingStatistics: _openLandlordDashboard,
                onOpenSubscription: _openSubscription,
              ),
            ),
          SettingsSection(
            title: 'Support',
            tiles: SettingsTileGroups.support(
              onOpenHelpCenter: _openHelpCenter,
              onContactSupport: _openContactSupport,
            ),
          ),
          SettingsSection(
            title: 'Legal',
            tiles: SettingsTileGroups.legal(
              onOpenPrivacyPolicy: _openPrivacyPolicy,
              onOpenTerms: _openTerms,
            ),
          ),
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

class _SettingsBottomSheet extends StatelessWidget {
  const _SettingsBottomSheet({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize: 0.32,
      maxChildSize: 0.88,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppDesign.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppDesign.border(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppDesign.accentTint(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(icon, color: AppDesign.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppDesign.text(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...children,
            ],
          ),
        );
      },
    );
  }
}

class _SettingsDetailRow extends StatelessWidget {
  const _SettingsDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(
                color: AppDesign.muted(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppDesign.text(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppDesign.surface(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppDesign.text(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppDesign.muted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(trailing, color: AppDesign.subtle(context), size: 21),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsChoiceRow extends StatelessWidget {
  const _SettingsChoiceRow({
    required this.title,
    required this.subtitle,
    required this.selected,
  });

  final String title;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? AppDesign.accentTint(context) : AppDesign.page(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppDesign.text(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppDesign.muted(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            const Icon(
              Icons.check_circle_rounded,
              color: AppDesign.accent,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _SettingsFaqItem extends StatelessWidget {
  const _SettingsFaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              color: AppDesign.text(context),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              color: AppDesign.muted(context),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetPrimaryButton extends StatelessWidget {
  const _SheetPrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDesign.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
