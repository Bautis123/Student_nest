import 'package:flutter/material.dart';

import 'admin_empty_state.dart';
import 'admin_filter_toggle.dart';
import 'admin_landlord_list_item.dart';

class AdminDashboardLandlordsTab extends StatefulWidget {
  final List<dynamic> landlords;
  final Future<void> Function(String) onApprove;
  final Future<void> Function(String) onReject;
  final Future<void> Function() onRefresh;

  const AdminDashboardLandlordsTab({
    super.key,
    required this.landlords,
    required this.onApprove,
    required this.onReject,
    required this.onRefresh,
  });

  @override
  State<AdminDashboardLandlordsTab> createState() =>
      _AdminDashboardLandlordsTabState();
}

class _AdminDashboardLandlordsTabState
    extends State<AdminDashboardLandlordsTab> {
  bool _showPending = false;

  @override
  Widget build(BuildContext context) {
    final pending = widget.landlords
        .where((landlord) => landlord['is_approved'] == false)
        .toList();
    final items = _showPending ? pending : widget.landlords;

    return Column(
      children: [
        AdminFilterToggle(
          isFirstSelected: !_showPending,
          firstLabel: 'All (${widget.landlords.length})',
          secondLabel: 'Pending (${pending.length})',
          secondBadgeCount: pending.length,
          onFirstTap: () => setState(() => _showPending = false),
          onSecondTap: () => setState(() => _showPending = true),
        ),
        const Divider(height: 1),
        Expanded(
          child: items.isEmpty
              ? AdminEmptyState(
                  icon: _showPending
                      ? Icons.check_circle_outline
                      : Icons.people_outline,
                  message: _showPending
                      ? 'No pending landlords'
                      : 'No landlords yet',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final landlord = items[index];
                    return AdminLandlordListItem(
                      landlord: landlord,
                      onApprove: () => widget.onApprove(landlord['id']),
                      onReject: () => widget.onReject(landlord['id']),
                      onRefresh: widget.onRefresh,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
