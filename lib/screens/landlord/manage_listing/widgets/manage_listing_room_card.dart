import 'package:flutter/material.dart';

import '../../../../models/property.dart';
import '../../../../utils/theme.dart';

class ManageListingRoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  const ManageListingRoomCard({
    super.key,
    required this.room,
    this.onDecrease,
    this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final occupancyText = room.availableRooms == 0
        ? 'Full — no rooms available'
        : room.availableRooms == room.totalRooms
            ? 'All rooms available'
            : '${room.totalRooms - room.availableRooms} '
                'room${room.totalRooms - room.availableRooms > 1 ? 's' : ''} occupied';

    final occupancyColor = room.availableRooms == 0
        ? AppTheme.error
        : room.availableRooms == room.totalRooms
            ? AppTheme.success
            : AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
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
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bed_outlined,
                  color: AppTheme.primary,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${room.studentsPerRoom} '
                      'student${room.studentsPerRoom > 1 ? 's' : ''}/room '
                      '· K${room.pricePerMonth.toStringAsFixed(0)}/mo',
                      style: const TextStyle(fontSize: 12, color: AppTheme.gray),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available rooms',
                style: TextStyle(fontSize: 13, color: AppTheme.gray),
              ),
              Row(
                children: [
                  _StepButton(icon: Icons.remove, onTap: onDecrease),
                  const SizedBox(width: 12),
                  Text(
                    '${room.availableRooms}/${room.totalRooms}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.dark,
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
              backgroundColor: AppTheme.border,
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
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppTheme.primary),
      ),
    );
  }
}

