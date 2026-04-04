import 'package:flutter/material.dart';

class BankDetailsForm extends StatelessWidget {
  final TextEditingController accountNameController;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final VoidCallback onChanged;

  const BankDetailsForm({
    super.key,
    required this.accountNameController,
    required this.bankNameController,
    required this.accountNumberController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: accountNameController,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(labelText: 'Account holder name'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: bankNameController,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(labelText: 'Bank name'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: accountNumberController,
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Account or card number',
          ),
        ),
      ],
    );
  }
}
