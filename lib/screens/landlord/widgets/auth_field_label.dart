import 'package:flutter/material.dart';

class AuthFieldLabel extends StatelessWidget {
  final String label;

  const AuthFieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
