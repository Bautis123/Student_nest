import 'package:flutter/material.dart';

import '../../../utils/theme.dart';

class ManageLandlordEmptyProperties extends StatelessWidget {
  const ManageLandlordEmptyProperties({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Center(
        child: Text(
          'No listings yet',
          style: TextStyle(color: AppTheme.gray),
        ),
      ),
    );
  }
}
