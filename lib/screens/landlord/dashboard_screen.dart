import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/sn_loading_indicator.dart';
import 'manage_listing_screen.dart';
import 'dashboard/dashboard_body.dart';
import 'dashboard/dashboard_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.listingsOnly = false,
    this.onAddListing,
  });

  final bool listingsOnly;
  final VoidCallback? onAddListing;

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
      return const SliverFillRemaining(child: SNLoadingIndicator());
    }

    return SliverToBoxAdapter(
      child: DashboardBody(
        properties: _properties,
        totalViews: _totalViews,
        totalClicks: _totalClicks,
        activeListings: _activeListings,
        pendingListings: _pendingListings,
        onOpenListing: _openManageListing,
        listingsOnly: widget.listingsOnly,
        onAddListing: widget.onAddListing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.page(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child:
                widget.listingsOnly
                    ? const _ListingsHeader()
                    : DashboardHeader(
                      landlordName: _landlordName ?? 'Landlord',
                    ),
          ),
          _buildContent(),
        ],
      ),
    );
  }
}

class _ListingsHeader extends StatelessWidget {
  const _ListingsHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Listings',
              style: TextStyle(
                color: AppDesign.text(context),
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Review status, interest, and listing details.',
              style: TextStyle(
                color: AppDesign.muted(context),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
