import 'package:flutter/material.dart';
import 'listing_payment_state.dart';
import 'listing_payment_view.dart';

class ListingPaymentScreen extends StatefulWidget {
  final String selectedPlan;

  const ListingPaymentScreen({super.key, required this.selectedPlan});

  @override
  State<ListingPaymentScreen> createState() => _ListingPaymentScreenState();
}

class _ListingPaymentScreenState extends State<ListingPaymentScreen> {
  late final ListingPaymentState state;

  @override
  void initState() {
    super.initState();
    state = ListingPaymentState(selectedPlan: widget.selectedPlan);
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
      builder: (_, __) => ListingPaymentView(state: state),
    );
  }
}
