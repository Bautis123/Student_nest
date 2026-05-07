import 'package:flutter/material.dart';
import '../../../../utils/app_design.dart';

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
          decoration: InputDecoration(
            labelText: 'Phone number',
            hintText: '097XXXXXXX',
            prefixIcon: Icon(Icons.phone_outlined, color: AppDesign.muted(context)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: nameController,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: 'Wallet account name',
            hintText: 'Enter the name on the mobile wallet',
            prefixIcon: Icon(Icons.person_outline, color: AppDesign.muted(context)),
          ),
        ),
      ],
    );
  }
}
