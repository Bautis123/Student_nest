import 'package:flutter/material.dart';

import '../../../models/property.dart';
import '../../../services/api_service.dart';
import 'package:student_nest/core/widgets/sn_button.dart';
import 'widgets/add_room_dialog.dart';
import 'widgets/manage_listing_empty_rooms.dart';
import 'widgets/manage_listing_room_card.dart';

class ManageListingRoomsTab extends StatefulWidget {
  final Property property;
  final VoidCallback onUpdated;

  const ManageListingRoomsTab({
    super.key,
    required this.property,
    required this.onUpdated,
  });

  @override
  State<ManageListingRoomsTab> createState() => _ManageListingRoomsTabState();
}

class _ManageListingRoomsTabState extends State<ManageListingRoomsTab> {
  final ApiService _api = ApiService();

  Future<void> _openAddRoomDialog() async {
    final roomPayload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddRoomDialog(),
    );

    if (roomPayload == null) return;

    await _api.addRooms(widget.property.id, [roomPayload]);
    widget.onUpdated();
  }

  Future<void> _updateRoomAvailability(Room room, int availableRooms) async {
    await _api.updateRoomAvailability(room.id, availableRooms);
    widget.onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = widget.property.rooms;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SNButton(
            label: 'Add Room Type',
            onPressed: _openAddRoomDialog,
            leadingIcon: Icons.add,
            fullWidth: false,
          ),
          const SizedBox(height: 16),
          if (rooms.isEmpty)
            const ManageListingEmptyRooms()
          else
            ...rooms.map(
              (room) => ManageListingRoomCard(
                room: room,
                onDecrease:
                    room.availableRooms > 0
                        ? () => _updateRoomAvailability(
                          room,
                          room.availableRooms - 1,
                        )
                        : null,
                onIncrease:
                    room.availableRooms < room.totalRooms
                        ? () => _updateRoomAvailability(
                          room,
                          room.availableRooms + 1,
                        )
                        : null,
              ),
            ),
        ],
      ),
    );
  }
}
