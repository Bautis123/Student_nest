import 'package:flutter/material.dart';
import 'payment_details_state.dart';
import 'payment_details_view.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String selectedPlan;
  final String paymentMethod;

  const PaymentDetailsScreen({
    super.key,
    required this.selectedPlan,
    required this.paymentMethod,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  late final PaymentDetailsState state;

  @override
  void initState() {
    super.initState();
    state = PaymentDetailsState(
      selectedPlan: widget.selectedPlan,
      paymentMethod: widget.paymentMethod,
    );
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (_, __) => PaymentDetailsView(state: state),
    );
  }
}
