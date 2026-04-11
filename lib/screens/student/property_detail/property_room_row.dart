import 'package:flutter/material.dart';
import '../../../models/property.dart';
import '../../../utils/theme.dart';
import '../../../widgets/app_status_badge.dart';

class PropertyRoomRow extends StatelessWidget {
  final Room room;

  const PropertyRoomRow({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final isFull = room.availableRooms == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isFull ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isFull
                  ? AppTheme.error.withValues(alpha: 0.3)
                  : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _details(isFull)),
          Text(
            'K${room.pricePerMonth.toStringAsFixed(0)}/mo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isFull ? AppTheme.gray : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _details(bool isFull) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              room.roomType[0].toUpperCase() + room.roomType.substring(1),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(width: 8),
            AppStatusBadge(
              label: isFull ? 'Full' : '${room.availableRooms} available',
              color: isFull ? AppTheme.error : AppTheme.success,
              fontSize: 10,
              horizontalPadding: 7,
              verticalPadding: 2,
              radius: 10,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '${room.studentsPerRoom} student${room.studentsPerRoom > 1 ? 's' : ''} per room',
          style: const TextStyle(fontSize: 12, color: AppTheme.gray),
        ),
      ],
    );
  }
}
