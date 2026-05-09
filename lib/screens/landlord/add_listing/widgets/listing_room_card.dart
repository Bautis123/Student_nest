import 'package:flutter/material.dart';

import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/app_surface_card.dart';
import 'listing_counter.dart';

class ListingRoomCard extends StatelessWidget {
  const ListingRoomCard({
    super.key,
    required this.index,
    required this.room,
    required this.roomTypes,
    required this.canRemove,
    required this.onRemove,
    required this.onRoomTypeChanged,
    required this.onPriceChanged,
    required this.onStudentsChanged,
    required this.onTotalRoomsChanged,
  });

  final int index;
  final Map<String, dynamic> room;
  final List<String> roomTypes;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<String?> onRoomTypeChanged;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<int> onStudentsChanged;
  final ValueChanged<int> onTotalRoomsChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room Type ${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppDesign.text(context),
                ),
              ),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppDesign.muted(context),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: room['room_type'],
            decoration: const InputDecoration(
              labelText: 'Type',
              prefixIcon: Icon(Icons.bed_outlined),
            ),
            items:
                roomTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type[0].toUpperCase() + type.substring(1)),
                      ),
                    )
                    .toList(),
            onChanged: onRoomTypeChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Price per month (K)',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            onChanged: onPriceChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CounterField(
                  label: 'Students per room',
                  child: ListingCounter(
                    value: room['students_per_room'],
                    min: 1,
                    max: 10,
                    onChanged: onStudentsChanged,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CounterField(
                  label: 'Total rooms',
                  child: ListingCounter(
                    value: room['total_rooms'],
                    min: 1,
                    max: 50,
                    onChanged: onTotalRoomsChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterField extends StatelessWidget {
  const _CounterField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppDesign.muted(context)),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
