import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'dashboard/admin_dashboard_app_bar.dart';
import 'dashboard/admin_dashboard_badge.dart';
import 'dashboard/admin_dashboard_landlords_tab.dart';
import 'dashboard/admin_dashboard_listings_tab.dart';
import 'dashboard/admin_dashboard_overview_tab.dart';
import 'payments_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ApiService _api = ApiService();

  Map<String, dynamic> _stats = {};
  List<dynamic> _pendingLandlords = [];
  List<dynamic> _pendingProperties = [];
  List<dynamic> _allProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final stats = await _api.getAdminStats();
      final landlords = await _api.getLandlords();
      final pending = await _api.getAdminProperties(status: 'pending');
      final all = await _api.getAdminProperties();

      if (!mounted) return;
      setState(() {
        _stats = stats['stats'] ?? {};
        _pendingLandlords = landlords;
        _pendingProperties = pending;
        _allProperties = all;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveLandlord(String id) async {
    await _api.updateLandlordStatus(id, true);
    await _loadData();
    _showMessage('Landlord approved');
  }

  Future<void> _rejectLandlord(String id) async {
    await _api.updateLandlordStatus(id, false);
    await _loadData();
    _showMessage('Landlord rejected');
  }

  Future<void> _approveProperty(String id) async {
    await _api.updatePropertyStatus(id, true);
    await _loadData();
    _showMessage('Property approved and now live');
  }

  Future<void> _rejectProperty(String id) async {
    await _api.updatePropertyStatus(id, false);
    await _loadData();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          AdminDashboardAppBar(
            controller: _tabController,
            tabs: [
              _buildTabLabel(
                title: 'Overview',
                badgeCount: _stats['pending_landlords'] ?? 0,
              ),
              _buildTabLabel(
                title: 'Landlords',
                badgeCount:
                    _pendingLandlords
                        .where((landlord) => landlord['is_approved'] == false)
                        .length,
              ),
              const Tab(text: 'Payments'),
              _buildTabLabel(
                title: 'Listings',
                badgeCount: _pendingProperties.length,
              ),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  AdminDashboardOverviewTab(stats: _stats),
                  AdminDashboardLandlordsTab(
                    landlords: _pendingLandlords,
                    onApprove: _approveLandlord,
                    onReject: _rejectLandlord,
                    onRefresh: _loadData,
                  ),
                  const PaymentsScreen(),
                  AdminDashboardListingsTab(
                    pendingProperties: _pendingProperties,
                    allProperties: _allProperties,
                    onApprove: _approveProperty,
                    onReject: _rejectProperty,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Tab _buildTabLabel({required String title, int badgeCount = 0}) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          if (badgeCount > 0) AdminDashboardBadge(count: badgeCount),
        ],
      ),
    );
  }
}
