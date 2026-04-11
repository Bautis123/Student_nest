import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class SettingsLogoutDialog extends StatelessWidget {
  final Future<void> Function() onConfirm;

  const SettingsLogoutDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.error,
            minimumSize: const Size(80, 36),
          ),
          child: const Text('Log Out'),
        ),
      ],
    );
  }
}
