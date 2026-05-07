import 'package:flutter/material.dart';

import '../../../../utils/app_design.dart';

class ListingFieldLabel extends StatelessWidget {
  const ListingFieldLabel(this.label, {super.key});

  final String label;

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
