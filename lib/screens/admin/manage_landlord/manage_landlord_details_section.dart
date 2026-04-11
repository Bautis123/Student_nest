import 'package:flutter/material.dart';

import '../../../utils/theme.dart';
import 'manage_landlord_field_label.dart';

class ManageLandlordDetailsSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool hasChanges;
  final bool isLoading;
  final VoidCallback onChanged;
  final VoidCallback onSave;

  const ManageLandlordDetailsSection({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.hasChanges,
    required this.isLoading,
    required this.onChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Landlord Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 12),
        ManageLandlordFieldLabel(label: 'Full Name'),
        const SizedBox(height: 6),
        TextField(
          controller: nameController,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        ManageLandlordFieldLabel(label: 'Phone Number'),
        const SizedBox(height: 6),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 12),
        ManageLandlordFieldLabel(label: 'Email'),
        const SizedBox(height: 6),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 20),
        if (hasChanges)
          ElevatedButton(
            onPressed: isLoading ? null : onSave,
            child: const Text('Save Changes'),
          ),
      ],
    );
  }
}
