import 'package:flutter/material.dart';

import 'payment_list_item.dart';

class PaymentsList extends StatelessWidget {
  final List<dynamic> payments;

  const PaymentsList({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (_, index) => PaymentListItem(payment: payments[index]),
    );
  }
}
