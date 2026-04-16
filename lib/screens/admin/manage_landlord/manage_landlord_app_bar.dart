import 'package:flutter/material.dart';

import '../../../utils/theme.dart';
import '../../../widgets/app_header_background.dart';

class ManageLandlordAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isApproved;
  final VoidCallback onToggleApproval;
  final VoidCallback onResetPassword;
  final VoidCallback onDeleteLandlord;

  const ManageLandlordAppBar({
    super.key,
    required this.isApproved,
    required this.onToggleApproval,
    required this.onResetPassword,
    required this.onDeleteLandlord,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Manage Landlord'),
      backgroundColor: Colors.transparent,
      foregroundColor: AppTheme.dark,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: const AppHeaderBackground(),
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppTheme.dark),
          onSelected: (value) {
            if (value == 'toggle') onToggleApproval();
            if (value == 'reset') onResetPassword();
            if (value == 'delete') onDeleteLandlord();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    isApproved
                        ? Icons.block_outlined
                        : Icons.check_circle_outline,
                    size: 18,
                    color: isApproved ? AppTheme.warning : AppTheme.success,
                  ),
                  const SizedBox(width: 10),
                  Text(isApproved ? 'Suspend' : 'Approve'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.lock_reset_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Reset Password'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                  SizedBox(width: 10),
                  Text(
                    'Delete Landlord',
                    style: TextStyle(color: AppTheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
