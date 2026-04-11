import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import 'payment_success_state.dart';
import 'widgets/payment_actions_bar.dart';
import 'widgets/payment_status_card.dart';
import 'widgets/receipt_details_card.dart';

class PaymentSuccessView extends StatelessWidget {
  final PaymentSuccessState state;

  const PaymentSuccessView({super.key, required this.state});

  void _goBackToDashboard(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(title: const Text('Payment Success')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PaymentStatusCard(
                    planTitle: state.planTitle,
                    amount: state.amount,
                  ),
                  const SizedBox(height: 16),
                  ReceiptDetailsCard(
                    planTitle: state.planTitle,
                    paymentMethod: state.paymentMethodLabel,
                    amount: state.amount,
                    nextExpiry: state.nextExpiry,
                  ),
                ],
              ),
            ),
          ),
          PaymentActionsBar(
            onDone: () => _goBackToDashboard(context),
            onViewListings: () => _goBackToDashboard(context),
          ),
        ],
      ),
    );
  }
}

