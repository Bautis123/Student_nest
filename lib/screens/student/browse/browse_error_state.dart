import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_theme.dart';
import 'package:student_nest/core/widgets/sn_button.dart';

class BrowseErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const BrowseErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: AppTheme.gray),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppTheme.gray)),
          const SizedBox(height: 16),
          SNButton(
            label: 'Retry',
            onPressed: onRetry,
            fullWidth: false,
            height: 44,
          ),
        ],
      ),
    );
  }
}
