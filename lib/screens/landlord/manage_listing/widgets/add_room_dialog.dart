import 'package:flutter/material.dart';

import '../../../../utils/app_design.dart';

class AddRoomDialog extends StatefulWidget {
  const AddRoomDialog({super.key});

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final TextEditingController _priceController = TextEditingController();
  final List<String> _roomTypes = const [
    'single',
    'double',
    'shared',
    'self-contained',
  ];

  int _studentsPerRoom = 1;
  int _totalRooms = 1;
  String _selectedType = 'single';

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_priceController.text.isEmpty) return;

    Navigator.pop(context, {
      'room_type': _selectedType,
      'price_per_month': double.parse(_priceController.text),
      'students_per_room': _studentsPerRoom,
      'total_rooms': _totalRooms,
      'available_rooms': _totalRooms,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppDesign.surface(context),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Add Room Type',
        style: TextStyle(color: AppDesign.text(context)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Room Type'),
              items: _roomTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type[0].toUpperCase() + type.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price per month'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CounterField(
                    label: 'Students/room',
                    value: _studentsPerRoom,
                    onDecrement: () {
                      if (_studentsPerRoom > 1) {
                        setState(() => _studentsPerRoom--);
                      }
                    },
                    onIncrement: () => setState(() => _studentsPerRoom++),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CounterField(
                    label: 'Total rooms',
                    value: _totalRooms,
                    onDecrement: () {
                      if (_totalRooms > 1) {
                        setState(() => _totalRooms--);
                      }
                    },
                    onIncrement: () => setState(() => _totalRooms++),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppDesign.accent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CounterField({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppDesign.muted(context)),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onDecrement,
              color: AppDesign.accent,
              icon: const Icon(Icons.remove),
            ),
            Text(
              '$value',
              style: TextStyle(color: AppDesign.text(context)),
            ),
            IconButton(
              onPressed: onIncrement,
              color: AppDesign.accent,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
