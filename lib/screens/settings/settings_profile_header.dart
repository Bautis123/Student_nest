import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/theme.dart';

class SettingsProfileHeader extends StatelessWidget {
  final User? user;

  const SettingsProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              user != null ? Icons.person_rounded : Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user != null ? user!.fullName : 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user != null ? user!.phone : 'Not logged in',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (user != null) _SettingsRoleChip(role: user!.role),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRoleChip extends StatelessWidget {
  final String role;

  const _SettingsRoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role[0].toUpperCase() + role.substring(1),
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
