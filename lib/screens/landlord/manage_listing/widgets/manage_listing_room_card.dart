import 'package:flutter/material.dart';

import '../../../../models/property.dart';
import '../../../../utils/app_design.dart';
import '../../../../utils/theme.dart';

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
    final occupiedRooms = room.totalRooms - room.availableRooms;
    final occupancyText =
        room.availableRooms == 0
            ? 'Full - no rooms available'
            : room.availableRooms == room.totalRooms
                ? 'All rooms available'
                : '$occupiedRooms room${occupiedRooms > 1 ? 's' : ''} occupied';

    final occupancyColor =
        room.availableRooms == 0
            ? AppTheme.error
            : room.availableRooms == room.totalRooms
                ? AppDesign.accent
                : AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppDesign.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppDesign.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bed_outlined,
                  color: AppDesign.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.roomType[0].toUpperCase() + room.roomType.substring(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppDesign.text(context),
                      ),
                    ),
                    Text(
                      '${room.studentsPerRoom} '
                      'student${room.studentsPerRoom > 1 ? 's' : ''}/room '
                      '- K${room.pricePerMonth.toStringAsFixed(0)}/mo',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppDesign.muted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppDesign.border(context)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available rooms',
                style: TextStyle(fontSize: 13, color: AppDesign.muted(context)),
              ),
              Row(
                children: [
                  _StepButton(icon: Icons.remove, onTap: onDecrease),
                  const SizedBox(width: 12),
                  Text(
                    '${room.availableRooms}/${room.totalRooms}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppDesign.text(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StepButton(icon: Icons.add, onTap: onIncrease),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: room.totalRooms > 0 ? room.availableRooms / room.totalRooms : 0,
              backgroundColor: AppDesign.border(context),
              valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            occupancyText,
            style: TextStyle(fontSize: 11, color: occupancyColor),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled
              ? AppDesign.accentTint(context)
              : AppDesign.border(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppDesign.accent : AppDesign.subtle(context),
        ),
      ),
    );
  }
}
