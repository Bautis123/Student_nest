import 'package:flutter/material.dart';
import 'package:student_nest/features/landlord/widgets/room_type_card.dart';

import '../../../../models/property.dart';

class ManageListingRoomCard extends StatelessWidget {
  const ManageListingRoomCard({
    super.key,
    required this.room,
    this.onDecrease,
    this.onIncrease,
  });

  final Room room;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return RoomTypeCard(
      room: room,
      onAvailabilityChanged: (availableRooms) {
        if (availableRooms < room.availableRooms) {
          onDecrease?.call();
          return;
        }
        if (availableRooms > room.availableRooms) {
          onIncrease?.call();
        }
      },
    );
  }
}
