import 'package:flutter/material.dart';

import '../../../utils/theme.dart';

class ManageLandlordFieldLabel extends StatelessWidget {
  final String label;

  const ManageLandlordFieldLabel({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.dark,
      ),
    );
  }
}
