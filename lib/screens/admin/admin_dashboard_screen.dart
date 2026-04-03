import 'payments_screen.dart';
import 'manage_landlord_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
      setState(() {
        _stats = stats['stats'] ?? {};
        _pendingLandlords = landlords as List;
        _pendingProperties = pending;
        _allProperties = all;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveLandlord(String id) async {
    await _api.updateLandlordStatus(id, true);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Landlord approved')));
    }
  }

  Future<void> _rejectLandlord(String id) async {
    await _api.updateLandlordStatus(id, false);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Landlord rejected')));
    }
  }

  Future<void> _approveProperty(String id) async {
    await _api.updatePropertyStatus(id, true);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property approved and now live')),
      );
    }
  }

  Future<void> _rejectProperty(String id) async {
    await _api.updatePropertyStatus(id, false);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFF1E293B),
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Bautis Digital Innovations',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Overview'),
                                if (_stats['pending_landlords'] != null &&
                                    _stats['pending_landlords'] > 0)
                                  _badge(_stats['pending_landlords']),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Landlords'),
                                if (_stats['_pendingLandlords'] != null &&
                                    _stats['pending_landlords'] > 0)
                                  _badge(_pendingLandlords.length),
                              ],
                            ),
                          ),

                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [const Text('Payments')],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Listings'),
                                if (_pendingProperties.isNotEmpty)
                                  _badge(_pendingProperties.length),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                  _OverviewTab(stats: _stats),
                  _LandlordsTab(
                    pendingLandlords: _pendingLandlords,
                    onApprove: _approveLandlord,
                    onReject: _rejectLandlord,
                    onRefresh: _loadData,
                  ),
                  _ListingsTab(
                    pendingProperties: _pendingProperties,
                    allProperties: _allProperties,
                    onApprove: _approveProperty,
                    onReject: _rejectProperty,
                  ),
                  const PaymentsScreen(), // Placeholder for payments tab
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(int count) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}

// ── OVERVIEW TAB ──────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _OverviewTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.dark,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _statCard(
                'Total Landlords',
                '${stats['total_landlords'] ?? 0}',
                Icons.person_outline,
                AppTheme.primary,
              ),
              _statCard(
                'Pending Approval',
                '${stats['pending_landlords'] ?? 0}',
                Icons.hourglass_empty_outlined,
                AppTheme.warning,
              ),
              _statCard(
                'Live Listings',
                '${stats['total_properties'] ?? 0}',
                Icons.home_work_outlined,
                AppTheme.success,
              ),
              _statCard(
                'Pending Listings',
                '${stats['pending_properties'] ?? 0}',
                Icons.pending_outlined,
                AppTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Revenue',
                      style: TextStyle(fontSize: 12, color: AppTheme.gray),
                    ),
                    Text(
                      'K${(stats['total_revenue'] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppTheme.gray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── LANDLORDS TAB ─────────────────────────────────────────────

class _LandlordsTab extends StatefulWidget {
  final List<dynamic> pendingLandlords;
  final Function(String) onApprove;
  final Function(String) onReject;
  final VoidCallback onRefresh;

  const _LandlordsTab({
    required this.pendingLandlords,
    required this.onApprove,
    required this.onReject,
    required this.onRefresh,
  });

  @override
  State<_LandlordsTab> createState() => _LandlordsTabState();
}

class _LandlordsTabState extends State<_LandlordsTab> {
  bool _showPending = false;

  @override
  Widget build(BuildContext context) {
    final pending =
        widget.pendingLandlords
            .where((l) => l['is_approved'] == false)
            .toList();
    final approved =
        widget.pendingLandlords.where((l) => l['is_approved'] == true).toList();
    final items = _showPending ? pending : widget.pendingLandlords;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showPending = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          !_showPending ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'All (${widget.pendingLandlords.length})',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: !_showPending ? Colors.white : AppTheme.gray,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showPending = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          _showPending ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pending (${pending.length})',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _showPending ? Colors.white : AppTheme.gray,
                          ),
                        ),
                        if (pending.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _showPending ? Colors.white : AppTheme.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${pending.length}',
                              style: TextStyle(
                                color:
                                    _showPending
                                        ? AppTheme.error
                                        : Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child:
              items.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showPending
                              ? Icons.check_circle_outline
                              : Icons.people_outline,
                          size: 48,
                          color: AppTheme.success,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _showPending
                              ? 'No pending landlords'
                              : 'No landlords yet',
                          style: const TextStyle(
                            color: AppTheme.gray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final landlord = items[i];
                      final isPending = landlord['is_approved'] == false;
                      return GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ManageLandlordScreen(
                                      landlord: landlord,
                                    ),
                              ),
                            ).then((_) => widget.onRefresh()),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          landlord['full_name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          landlord['phone'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.gray,
                                          ),
                                        ),
                                        if (landlord['email'] != null)
                                          Text(
                                            landlord['email'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.gray,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isPending
                                              ? AppTheme.warning.withOpacity(
                                                0.1,
                                              )
                                              : AppTheme.success.withOpacity(
                                                0.1,
                                              ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isPending ? 'Pending' : 'Active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isPending
                                                ? AppTheme.warning
                                                : AppTheme.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isPending) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed:
                                            () =>
                                                widget.onReject(landlord['id']),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.error,
                                          side: BorderSide(
                                            color: AppTheme.error.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                          minimumSize: const Size(
                                            double.infinity,
                                            38,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            () => widget.onApprove(
                                              landlord['id'],
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.success,
                                          minimumSize: const Size(
                                            double.infinity,
                                            38,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

// ── LISTINGS TAB ──────────────────────────────────────────────

class _ListingsTab extends StatefulWidget {
  final List<dynamic> pendingProperties;
  final List<dynamic> allProperties;
  final Function(String) onApprove;
  final Function(String) onReject;

  const _ListingsTab({
    required this.pendingProperties,
    required this.allProperties,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_ListingsTab> createState() => _ListingsTabState();
}

class _ListingsTabState extends State<_ListingsTab> {
  bool _showPending = true;

  @override
  Widget build(BuildContext context) {
    final items =
        _showPending ? widget.pendingProperties : widget.allProperties;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showPending = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          _showPending ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Pending (${widget.pendingProperties.length})',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _showPending ? Colors.white : AppTheme.gray,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showPending = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          !_showPending ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'All (${widget.allProperties.length})',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: !_showPending ? Colors.white : AppTheme.gray,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child:
              items.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: AppTheme.success,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _showPending
                              ? 'No pending listings'
                              : 'No listings yet',
                          style: const TextStyle(
                            color: AppTheme.gray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final property = items[i];
                      final isPending = property['is_approved'] == false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.home_work_outlined,
                                    color: AppTheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        property['title'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        property['landlord_name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.gray,
                                        ),
                                      ),
                                      Text(
                                        property['address'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.gray,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isPending
                                            ? AppTheme.warning.withOpacity(0.1)
                                            : AppTheme.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isPending ? 'Pending' : 'Live',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isPending
                                              ? AppTheme.warning
                                              : AppTheme.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isPending) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed:
                                          () => widget.onReject(property['id']),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.error,
                                        side: BorderSide(
                                          color: AppTheme.error.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                        minimumSize: const Size(
                                          double.infinity,
                                          38,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          () =>
                                              widget.onApprove(property['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.success,
                                        minimumSize: const Size(
                                          double.infinity,
                                          38,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
