import 'package:flutter/material.dart';
import 'package:student_nest/core/constants/app_strings.dart';
import 'package:student_nest/core/widgets/sn_button.dart';

class SettingsLogoutDialog extends StatelessWidget {
  final Future<void> Function() onConfirm;

  const SettingsLogoutDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(AppStrings.logOut),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        SNButton(
          label: AppStrings.logOut,
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          variant: SNButtonVariant.danger,
          fullWidth: false,
          height: 36,
        ),
      ],
    );
  }
}
