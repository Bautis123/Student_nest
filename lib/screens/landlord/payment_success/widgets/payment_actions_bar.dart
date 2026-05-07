import 'package:flutter/material.dart';
import '../../../../utils/app_design.dart';
import '../../../../utils/theme.dart';
import '../../../../widgets/app_bottom_action_bar.dart';

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
            child: ElevatedButton(onPressed: onDone, child: const Text('Done')),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewListings,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary, width: 1.4),
                backgroundColor: AppDesign.surface(context),
              ),
              child: const Text('View Listings'),
            ),
          ),
        ],
      ),
    );
  }
}

