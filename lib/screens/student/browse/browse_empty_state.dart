import 'package:flutter/material.dart';
import '../../../utils/student_nest_icons.dart';
import '../../../utils/theme.dart';

class BrowseEmptyState extends StatelessWidget {
  const BrowseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StudentNestIcon(
            StudentNestIcons.building,
            size: 48,
            color: AppTheme.gray,
          ),
          SizedBox(height: 12),
          Text('No listings found', style: TextStyle(color: AppTheme.gray)),
        ],
      ),
    );
  }
}
