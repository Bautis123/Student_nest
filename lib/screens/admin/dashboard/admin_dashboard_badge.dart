import 'package:flutter/material.dart';

import '../../../utils/theme.dart';

class AdminDashboardBadge extends StatelessWidget {
  final int count;

  const AdminDashboardBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
