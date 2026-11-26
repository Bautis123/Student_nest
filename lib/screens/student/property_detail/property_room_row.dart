import 'package:flutter/material.dart';
import '../../../models/property.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/utils/formatters.dart';
import 'package:student_nest/core/widgets/app_status_badge.dart';

class PropertyRoomRow extends StatelessWidget {
  final Room room;

  const PropertyRoomRow({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final isFull = room.availableRooms == 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppDesign.border(context))),
      ),
      child: Row(
        children: [
          Expanded(child: _details(context, isFull)),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                Formatters.monthPrice(room.pricePerMonth),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFull ? AppDesign.muted(context) : AppDesign.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: isFull ? AppDesign.muted(context) : AppDesign.accent,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context, bool isFull) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                Formatters.titleCaseWord(room.roomType),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppDesign.text(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AppStatusBadge(
              label: isFull ? 'Full' : '${room.availableRooms} available',
              color: isFull ? AppColors.error : AppColors.success,
              fontSize: 12,
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
          style: TextStyle(fontSize: 15, color: AppDesign.muted(context)),
        ),
      ],
    );
  }
}
