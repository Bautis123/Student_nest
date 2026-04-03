import 'manage_listing_screen.dart';
import 'add_listing_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/property.dart';
import '../../utils/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _landlordName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _api.getUser();
      final properties = await _api.getMyProperties();
      setState(() {
        _landlordName = user?.fullName;
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int get _totalViews => _properties.fold(0, (sum, p) => sum + p.viewCount);

  int get _totalClicks =>
      _properties.fold(0, (sum, p) => sum + p.contactClickCount);

  int get _activeListings =>
      _properties.where((p) => p.isApproved && p.isActive).length;

  int get _pendingListings => _properties.where((p) => !p.isApproved).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _landlordName ?? 'Landlord',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _statCard(
                          'Total Views',
                          _totalViews.toString(),
                          Icons.visibility_outlined,
                          AppTheme.primary,
                        ),
                        _statCard(
                          'Contact Clicks',
                          _totalClicks.toString(),
                          Icons.phone_outlined,
                          AppTheme.success,
                        ),
                        _statCard(
                          'Active Listings',
                          _activeListings.toString(),
                          Icons.check_circle_outline,
                          const Color(0xFF8B5CF6),
                        ),
                        _statCard(
                          'Pending',
                          _pendingListings.toString(),
                          Icons.hourglass_empty_outlined,
                          AppTheme.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // My listings header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Listings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.dark,
                          ),
                        ),
                        TextButton.icon(
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddListingScreen(),
                                ),
                              ).then((_) => _loadData()),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add New'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Listings
                    if (_properties.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.home_work_outlined,
                                size: 48,
                                color: AppTheme.gray,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No listings yet',
                                style: TextStyle(
                                  color: AppTheme.gray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap Add New to create your first listing',
                                style: TextStyle(
                                  color: AppTheme.gray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._properties.map((p) => _propertyRow(p)),
                  ],
                ),
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

  Widget _propertyRow(Property p) {
    final isApproved = p.isApproved;
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ManageListingScreen(property: p)),
          ).then((_) => _loadData()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.home_work_outlined,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.address,
                    style: const TextStyle(fontSize: 12, color: AppTheme.gray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 12,
                        color: AppTheme.gray,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${p.viewCount} views',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.gray,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.phone_outlined,
                        size: 12,
                        color: AppTheme.gray,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${p.contactClickCount} clicks',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.gray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isApproved
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isApproved ? 'Active' : 'Pending',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isApproved ? AppTheme.success : AppTheme.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
