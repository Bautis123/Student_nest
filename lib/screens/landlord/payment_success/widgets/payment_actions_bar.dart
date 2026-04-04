import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
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
              child: const Text('View Listings'),
            ),
          ),
        ],
      ),
    );
  }
}
