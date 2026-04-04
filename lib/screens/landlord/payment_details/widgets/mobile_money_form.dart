import 'package:flutter/material.dart';

class MobileMoneyForm extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final VoidCallback onChanged;

  const MobileMoneyForm({
    super.key,
    required this.phoneController,
    required this.nameController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Phone number',
            hintText: '097XXXXXXX',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: nameController,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Wallet account name',
            hintText: 'Enter the name on the mobile wallet',
          ),
        ),
      ],
    );
  }
}
