import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class DashboardHeader extends StatelessWidget {
  final String landlordName;

  const DashboardHeader({super.key, required this.landlordName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          Text(
            landlordName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
