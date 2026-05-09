import 'package:flutter/material.dart';
import 'package:student_nest/features/landlord/widgets/stat_card.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return StatCard(icon: icon, value: value, label: label, iconBgColor: color);
  }
}
