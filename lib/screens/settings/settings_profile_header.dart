import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../utils/app_design.dart';
import '../../utils/student_nest_icons.dart';

class SettingsProfileHeader extends StatelessWidget {
  final User? user;

  const SettingsProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user?.fullName ?? 'Guest';
    final status = user != null ? user!.phone : 'Not logged in';
    final badgeLabel =
        user != null ? _formatRole(user!.role) : 'Guest Mode';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDesign.surfaceDecoration(context),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppDesign.accentTint(context),
                borderRadius: BorderRadius.circular(999),
              ),
              child: StudentNestIcon(
                StudentNestIcons.profile,
                color: AppDesign.accent,
                size: user != null ? 27 : 29,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppDesign.text(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppDesign.muted(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ProfileBadge(label: badgeLabel, isGuest: user == null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatRole(String role) {
    if (role.isEmpty) return 'User';
    return role[0].toUpperCase() + role.substring(1);
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.label, required this.isGuest});

  final String label;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppDesign.accentTint(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGuest
                ? Icons.shield_outlined
                : Icons.check_circle_outline_rounded,
            size: 13,
            color: AppDesign.accent,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppDesign.accent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
