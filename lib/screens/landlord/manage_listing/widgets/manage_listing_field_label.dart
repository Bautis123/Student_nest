import 'package:flutter/material.dart';

import '../../../../utils/theme.dart';

class ManageListingFieldLabel extends StatelessWidget {
  final String label;

  const ManageListingFieldLabel(this.label, {super.key});

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
