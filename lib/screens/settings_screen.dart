import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'landlord/login_screen.dart';
import 'landlord/dashboard_screen.dart';
import 'main_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _api = ApiService();
  User? _user;
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _api.getUser();
    setState(() => _user = user);
  }

  Future<void> _logout() async {
    await _api.logout();
    setState(() => _user = null);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // Profile header
          _buildProfileHeader(),

          // General settings - always visible
          _buildSection('Settings', [
            _buildTile(
              icon: Icons.person_outline,
              iconColor: const Color(0xFF6366F1),
              title: 'Profile',
              subtitle: 'Edit your personal information',
              onTap: () {},
            ),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFFF59E0B),
              title: 'Notifications',
              subtitle: 'Receive listing alerts',
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              iconColor: const Color(0xFF1E293B),
              title: 'Dark Mode',
              subtitle: 'Switch app appearance',
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            _buildTile(
              icon: Icons.language_outlined,
              iconColor: const Color(0xFF10B981),
              title: 'Language',
              subtitle: 'English',
              onTap: () {},
            ),
          ]),

          // Student options - visible when not logged in or logged in as student
          if (_user == null || _user?.role == 'student')
            _buildSection('Student Options', [
              _buildTile(
                icon: Icons.favorite_outline,
                iconColor: const Color(0xFFEF4444),
                title: 'Saved Boarding Houses',
                subtitle: 'Your saved listings',
                onTap: () {},
              ),
              _buildTile(
                icon: Icons.school_outlined,
                iconColor: const Color(0xFF3B82F6),
                title: 'Preferred School',
                subtitle: 'University of Zambia',
                onTap: () {},
              ),
            ]),

          // Landlord options - visible when logged in as landlord
          if (_user?.role == 'landlord')
            _buildSection('Landlord Options', [
              _buildTile(
                icon: Icons.home_work_outlined,
                iconColor: const Color(0xFF1A56DB),
                title: 'My Boarding Houses',
                subtitle: 'Manage your listings',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    ),
              ),
              _buildTile(
                icon: Icons.bar_chart_outlined,
                iconColor: const Color(0xFF10B981),
                title: 'Listing Statistics',
                subtitle: 'Views and contact clicks',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    ),
              ),
              _buildTile(
                icon: Icons.card_membership_outlined,
                iconColor: const Color(0xFFF59E0B),
                title: 'Subscription',
                subtitle: 'Manage your listing plan',
                onTap: () {},
              ),
            ]),

          // Admin options
          if (_user?.role == 'admin')
            _buildSection('Admin Options', [
              _buildTile(
                icon: Icons.admin_panel_settings_outlined,
                iconColor: const Color(0xFF7C3AED),
                title: 'Admin Dashboard',
                subtitle: 'Manage the platform',
                onTap: () {},
              ),
            ]),

          // Support
          _buildSection('Support', [
            _buildTile(
              icon: Icons.help_outline,
              iconColor: const Color(0xFF0284C7),
              title: 'Help Center',
              subtitle: 'FAQs and guides',
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.support_agent_outlined,
              iconColor: const Color(0xFF10B981),
              title: 'Contact Support',
              subtitle: 'Get help from our team',
              onTap: () {},
            ),
          ]),

          // Legal
          _buildSection('Legal', [
            _buildTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: const Color(0xFF64748B),
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF64748B),
              title: 'Terms of Service',
              onTap: () {},
            ),
          ]),

          // Login / Logout
          _buildSection('Account', [
            if (_user == null)
              _buildTile(
                icon: Icons.login_outlined,
                iconColor: AppTheme.primary,
                title: 'Landlord Login',
                subtitle: 'List your property',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ).then((_) => _loadUser()),
              )
            else
              _buildTile(
                icon: Icons.logout_outlined,
                iconColor: AppTheme.error,
                title: 'Log Out',
                titleColor: AppTheme.error,
                onTap: () => _showLogoutDialog(),
              ),
          ]),

          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Student Nest v1.0.0\nBautis Digital Innovations Ltd',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppTheme.gray),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              _user != null ? Icons.person_rounded : Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user != null ? _user!.fullName : 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _user != null ? _user!.phone : 'Not logged in',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (_user != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _user!.role[0].toUpperCase() + _user!.role.substring(1),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? AppTheme.dark,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.dark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.gray),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('Log Out'),
              ),
            ],
          ),
    );
  }
}
