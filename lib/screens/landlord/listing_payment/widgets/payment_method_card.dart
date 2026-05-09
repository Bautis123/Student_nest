import 'package:flutter/material.dart';
import 'package:student_nest/features/landlord/widgets/payment_method_option.dart';

class PaymentMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PaymentMethodOption(
      name: title,
      subtitle: subtitle,
      isSelected: selected,
      onTap: onTap,
    );
  }
}
