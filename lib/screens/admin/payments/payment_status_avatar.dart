import 'package:flutter/material.dart';

import '../../../utils/theme.dart';

class PaymentStatusAvatar extends StatelessWidget {
  final bool isConfirmed;

  const PaymentStatusAvatar({
    super.key,
    required this.isConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isConfirmed
            ? AppTheme.success.withValues(alpha: 0.1)
            : AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(
        isConfirmed ? Icons.check_circle_outline : Icons.hourglass_empty_outlined,
        color: isConfirmed ? AppTheme.success : AppTheme.warning,
      ),
    );
  }
}
