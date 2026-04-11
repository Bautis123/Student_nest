import 'package:flutter/material.dart';

import 'admin_empty_state.dart';
import 'admin_filter_toggle.dart';
import 'admin_property_list_item.dart';

class AdminDashboardListingsTab extends StatefulWidget {
  final List<dynamic> pendingProperties;
  final List<dynamic> allProperties;
  final Future<void> Function(String) onApprove;
  final Future<void> Function(String) onReject;

  const AdminDashboardListingsTab({
    super.key,
    required this.pendingProperties,
    required this.allProperties,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<AdminDashboardListingsTab> createState() =>
      _AdminDashboardListingsTabState();
}

class _AdminDashboardListingsTabState extends State<AdminDashboardListingsTab> {
  bool _showPending = true;

  @override
  Widget build(BuildContext context) {
    final items =
        _showPending ? widget.pendingProperties : widget.allProperties;

    return Column(
      children: [
        AdminFilterToggle(
          isFirstSelected: _showPending,
          firstLabel: 'Pending (${widget.pendingProperties.length})',
          secondLabel: 'All (${widget.allProperties.length})',
          onFirstTap: () => setState(() => _showPending = true),
          onSecondTap: () => setState(() => _showPending = false),
        ),
        const Divider(height: 1),
        Expanded(
          child: items.isEmpty
              ? AdminEmptyState(
                  icon: Icons.check_circle_outline,
                  message: _showPending
                      ? 'No pending listings'
                      : 'No listings yet',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final property = items[index];
                    return AdminPropertyListItem(
                      property: property,
                      onApprove: () => widget.onApprove(property['id']),
                      onReject: () => widget.onReject(property['id']),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
