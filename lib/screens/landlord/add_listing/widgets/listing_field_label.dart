import 'package:flutter/material.dart';

import '../../../../utils/theme.dart';

class ListingFieldLabel extends StatelessWidget {
  const ListingFieldLabel(this.label, {super.key});

  final String label;

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
