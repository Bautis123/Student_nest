import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class DashboardHeader extends StatelessWidget {
  final String landlordName;

  const DashboardHeader({super.key, required this.landlordName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back',
            style: TextStyle(
              color: AppTheme.dark,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            landlordName,
            style: const TextStyle(
              color: AppTheme.dark,
              fontSize: 52,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _HeaderPill(
                icon: Icons.local_fire_department_outlined,
                label: 'Engagement up',
              ),
              const SizedBox(width: 8),
              _HeaderPill(
                icon: Icons.bolt_outlined,
                label: 'Live dashboard',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.dark,
            ),
          ),
        ],
      ),
    );
  }
}
