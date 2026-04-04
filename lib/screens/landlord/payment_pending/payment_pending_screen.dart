import 'package:flutter/material.dart';
import 'payment_pending_state.dart';
import 'payment_pending_view.dart';

class PaymentPendingScreen extends StatelessWidget {
  final String selectedPlan;
  final String paymentMethod;

  const PaymentPendingScreen({
    super.key,
    required this.selectedPlan,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return PaymentPendingView(
      state: PaymentPendingState(
        selectedPlan: selectedPlan,
        paymentMethod: paymentMethod,
      ),
    );
  }
}
