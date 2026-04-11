import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

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
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(minimumSize: const Size(160, 44)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
