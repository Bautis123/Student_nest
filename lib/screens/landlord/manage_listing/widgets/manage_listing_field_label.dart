import 'package:flutter/material.dart';

import '../../../../utils/app_design.dart';

class ManageListingFieldLabel extends StatelessWidget {
  final String label;

  const ManageListingFieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppDesign.text(context),
      ),
    );
  }
}
