import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../services/api_service.dart';
import 'package:student_nest/core/constants/app_strings.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/theme/app_theme.dart';
import 'package:student_nest/core/widgets/sn_loading_indicator.dart';
import 'package:student_nest/core/widgets/sn_button.dart';
import 'manage_listing/manage_listing_details_tab.dart';
import 'manage_listing/manage_listing_photos_tab.dart';
import 'manage_listing/manage_listing_rooms_tab.dart';

class ManageListingScreen extends StatefulWidget {
  final Property property;

  const ManageListingScreen({super.key, required this.property});

  @override
  State<ManageListingScreen> createState() => _ManageListingScreenState();
}

class _ManageListingScreenState extends State<ManageListingScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late final TabController _tabController;
  late Property _property;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _property = widget.property;
    _loadFullProperty();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFullProperty() async {
    try {
      final property = await _api.getPropertyById(_property.id);
      if (!mounted) return;
      setState(() => _property = property);
    } catch (_) {}
  }

  Future<void> _toggleActive() async {
    try {
      final nextIsActive = !_property.isActive;
      await _api.togglePropertyActive(_property.id, nextIsActive);
      await _loadFullProperty();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextIsActive ? 'Listing activated' : 'Listing deactivated',
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> _deleteListing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Listing'),
            content: const Text(
              'Are you sure you want to delete this listing? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text(AppStrings.cancel),
              ),
              SNButton(
                label: AppStrings.delete,
                onPressed: () => Navigator.pop(dialogContext, true),
                variant: SNButtonVariant.danger,
                fullWidth: false,
                height: 36,
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _api.deleteProperty(_property.id);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing deleted successfully')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _handleMenuAction(Object? value) {
    if (value == 'toggle') _toggleActive();
    if (value == 'delete') _deleteListing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.page(context),
      appBar: AppBar(
        title: Text(
          _property.title,
          style: TextStyle(fontSize: 16, color: AppDesign.text(context)),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppDesign.surface(context),
        foregroundColor: AppDesign.text(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton<Object?>(
            icon: Icon(Icons.more_vert, color: AppDesign.text(context)),
            onSelected: _handleMenuAction,
            itemBuilder:
                (_) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          _property.isActive
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(_property.isActive ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppTheme.error,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Delete Listing',
                          style: TextStyle(color: AppTheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppDesign.accent,
          labelColor: AppDesign.accent,
          unselectedLabelColor: AppDesign.muted(context),
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Photos'),
            Tab(text: 'Rooms'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const SNLoadingIndicator()
              : Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: Theme.of(
                    context,
                  ).inputDecorationTheme.copyWith(
                    prefixIconColor: AppDesign.subtle(context),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: AppDesign.accent,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ManageListingDetailsTab(
                      property: _property,
                      onUpdated: _loadFullProperty,
                    ),
                    ManageListingPhotosTab(
                      property: _property,
                      onUpdated: _loadFullProperty,
                    ),
                    ManageListingRoomsTab(
                      property: _property,
                      onUpdated: _loadFullProperty,
                    ),
                  ],
                ),
              ),
    );
  }
}
