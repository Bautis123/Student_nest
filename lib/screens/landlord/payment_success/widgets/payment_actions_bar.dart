import 'package:flutter/material.dart';
import 'package:student_nest/core/widgets/app_bottom_action_bar.dart';
import 'package:student_nest/core/widgets/sn_button.dart';

class PaymentActionsBar extends StatelessWidget {
  final VoidCallback onDone;
  final VoidCallback onViewListings;

  const PaymentActionsBar({
    super.key,
    required this.onDone,
    required this.onViewListings,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomActionBar(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: SNButton(label: 'Done', onPressed: onDone),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SNButton(
              label: 'View Listings',
              onPressed: onViewListings,
              variant: SNButtonVariant.outlined,
            ),
          ),
        ],
      ),
    );
  }
}
