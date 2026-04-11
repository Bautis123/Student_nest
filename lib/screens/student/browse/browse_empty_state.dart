import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class BrowseEmptyState extends StatelessWidget {
  const BrowseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 48, color: AppTheme.gray),
          SizedBox(height: 12),
          Text('No listings found', style: TextStyle(color: AppTheme.gray)),
        ],
      ),
    );
  }
}
