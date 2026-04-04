import 'package:flutter/material.dart';
import 'payment_success_state.dart';
import 'payment_success_view.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String selectedPlan;
  final String paymentMethod;

  const PaymentSuccessScreen({
    super.key,
    required this.selectedPlan,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final state = PaymentSuccessState(
      selectedPlan: selectedPlan,
      paymentMethod: paymentMethod,
    );

    return PaymentSuccessView(state: state);
  }
}
