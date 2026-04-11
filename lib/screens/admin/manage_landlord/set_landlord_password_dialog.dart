import 'package:flutter/material.dart';

class SetLandlordPasswordDialog extends StatefulWidget {
  const SetLandlordPasswordDialog({super.key});

  @override
  State<SetLandlordPasswordDialog> createState() =>
      _SetLandlordPasswordDialogState();
}

class _SetLandlordPasswordDialogState extends State<SetLandlordPasswordDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Set New Password'),
      content: TextField(
        controller: _controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: 'Enter new password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscureText = !_obscureText),
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Set Password'),
        ),
      ],
    );
  }
}
