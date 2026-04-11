import 'package:flutter/material.dart';

import '../../../../utils/theme.dart';
import 'listing_room_card.dart';

class AddListingRoomsPage extends StatelessWidget {
  const AddListingRoomsPage({
    super.key,
    required this.rooms,
    required this.roomTypes,
    required this.onAddRoom,
    required this.onRemoveRoom,
    required this.onRoomTypeChanged,
    required this.onPriceChanged,
    required this.onStudentsChanged,
    required this.onTotalRoomsChanged,
  });

  final List<Map<String, dynamic>> rooms;
  final List<String> roomTypes;
  final VoidCallback onAddRoom;
  final ValueChanged<int> onRemoveRoom;
  final void Function(int index, String? value) onRoomTypeChanged;
  final void Function(int index, String value) onPriceChanged;
  final void Function(int index, int value) onStudentsChanged;
  final void Function(int index, int value) onTotalRoomsChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Room Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.dark,
                ),
              ),
              TextButton.icon(
                onPressed: onAddRoom,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Type'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rooms.asMap().entries.map(
                (entry) => ListingRoomCard(
                  index: entry.key,
                  room: entry.value,
                  roomTypes: roomTypes,
                  canRemove: rooms.length > 1,
                  onRemove: () => onRemoveRoom(entry.key),
                  onRoomTypeChanged: (value) => onRoomTypeChanged(entry.key, value),
                  onPriceChanged: (value) => onPriceChanged(entry.key, value),
                  onStudentsChanged: (value) => onStudentsChanged(entry.key, value),
                  onTotalRoomsChanged: (value) => onTotalRoomsChanged(entry.key, value),
                ),
              ),
        ],
      ),
    );
  }
}
