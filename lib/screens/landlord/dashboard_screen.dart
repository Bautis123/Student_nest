import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import 'add_listing_screen.dart';
import 'manage_listing_screen.dart';
import 'dashboard/dashboard_body.dart';
import 'dashboard/dashboard_header.dart';

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

  Future<void> _openAddListing() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddListingScreen()),
    );
    _loadData();
  }

  Future<void> _openManageListing(Property property) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageListingScreen(property: property),
      ),
    );
    _loadData();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SliverToBoxAdapter(
      child: DashboardBody(
        properties: _properties,
        totalViews: _totalViews,
        totalClicks: _totalClicks,
        activeListings: _activeListings,
        pendingListings: _pendingListings,
        onAddNew: _openAddListing,
        onOpenListing: _openManageListing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: DashboardHeader(
                landlordName: _landlordName ?? 'Landlord',
              ),
            ),
          ),
          _buildContent(),
        ],
      ),
    );
  }
}

