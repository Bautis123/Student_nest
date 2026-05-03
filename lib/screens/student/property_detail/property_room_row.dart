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
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(child: _details(isFull)),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'K${room.pricePerMonth.toStringAsFixed(0)}/mo',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFull ? AppTheme.gray : AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: isFull ? AppTheme.gray : AppTheme.primary,
            size: 24,
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
            Flexible(
              child: Text(
                room.roomType[0].toUpperCase() + room.roomType.substring(1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.dark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AppStatusBadge(
              label: isFull ? 'Full' : '${room.availableRooms} available',
              color: isFull ? AppTheme.error : AppTheme.success,
              fontSize: 10,
              horizontalPadding: 7,
              verticalPadding: 3,
              radius: 10,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${room.studentsPerRoom} student${room.studentsPerRoom > 1 ? 's' : ''} per room',
          style: const TextStyle(fontSize: 13, color: Color(0xFF8A94A6)),
        ),
      ],
    );
  }
}
