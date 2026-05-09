import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';

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
          decoration: InputDecoration(
            labelText: 'Account holder name',
            prefixIcon: Icon(
              Icons.person_outline,
              color: AppDesign.muted(context),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: bankNameController,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: 'Bank name',
            prefixIcon: Icon(
              Icons.account_balance_outlined,
              color: AppDesign.muted(context),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: accountNumberController,
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: 'Account or card number',
            prefixIcon: Icon(
              Icons.credit_card_outlined,
              color: AppDesign.muted(context),
            ),
          ),
        ),
      ],
    );
  }
}
