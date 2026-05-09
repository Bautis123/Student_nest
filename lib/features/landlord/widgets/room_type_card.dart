import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/utils/formatters.dart';
import 'package:student_nest/core/widgets/sn_card.dart';
import 'package:student_nest/models/property.dart';

class RoomTypeCard extends StatelessWidget {
  const RoomTypeCard({
    super.key,
    required this.room,
    required this.onAvailabilityChanged,
  });

  final Room room;
  final ValueChanged<int> onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.titleCaseWord(room.roomType)),
                const SizedBox(height: 4),
                Text(
                  '${room.studentsPerRoom} student(s)/room - ${Formatters.monthPrice(room.pricePerMonth)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed:
                room.availableRooms > 0
                    ? () => onAvailabilityChanged(room.availableRooms - 1)
                    : null,
            icon: const Icon(Icons.remove),
          ),
          Text('${room.availableRooms}/${room.totalRooms}'),
          IconButton(
            onPressed:
                room.availableRooms < room.totalRooms
                    ? () => onAvailabilityChanged(room.availableRooms + 1)
                    : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
