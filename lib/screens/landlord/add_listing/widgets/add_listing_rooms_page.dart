import 'package:flutter/material.dart';

import '../../../../utils/app_design.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rooms',
            style: TextStyle(
              color: AppDesign.text(context),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add the room types available at this property.',
            style: TextStyle(
              color: AppDesign.muted(context),
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppDesign.text(context),
                ),
              ),
              TextButton(
                onPressed: onAddRoom,
                style: TextButton.styleFrom(
                  foregroundColor: AppDesign.accent,
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: const Text('+ Add room type'),
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
