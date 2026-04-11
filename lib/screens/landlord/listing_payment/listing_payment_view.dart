import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../../../widgets/app_surface_card.dart';
import '../payment_details/payment_details_screen.dart';
import 'listing_payment_state.dart';
import 'widgets/listing_payment_header_card.dart';
import 'widgets/payment_method_card.dart';
import 'widgets/payment_summary_card.dart';

class ListingPaymentView extends StatelessWidget {
  final ListingPaymentState state;

  const ListingPaymentView({super.key, required this.state});

  void _payNow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PaymentDetailsScreen(
              selectedPlan: state.selectedPlan,
              paymentMethod: state.paymentMethod,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(title: const Text('Listing Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListingPaymentHeaderCard(
              isPremium: state.isPremium,
              amount: state.amount,
            ),
            const SizedBox(height: 16),
            _methodsCard(),
            const SizedBox(height: 16),
            PaymentSummaryCard(
              planTitle: state.planTitle,
              amount: state.amount,
              onPayNow: () => _payNow(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodsCard() {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose payment method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (state.isPremium) _premiumInfo(),
          PaymentMethodCard(
            title: 'MTN Mobile Money',
            subtitle: 'Fastest for landlords in Zambia',
            selected: state.paymentMethod == 'mtn',
            onTap: () => state.selectMethod('mtn'),
          ),
          const SizedBox(height: 10),
          PaymentMethodCard(
            title: 'Airtel Money',
            subtitle: 'Pay using Airtel mobile wallet',
            selected: state.paymentMethod == 'airtel',
            onTap: () => state.selectMethod('airtel'),
          ),
          const SizedBox(height: 10),
          PaymentMethodCard(
            title: 'Bank card',
            subtitle: 'Visa or Mastercard',
            selected: state.paymentMethod == 'card',
            onTap: () => state.selectMethod('card'),
          ),
        ],
      ),
    );
  }

  Widget _premiumInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Text(
        'Premium listings get a premium badge and appear higher in student suggestions.',
        style: TextStyle(fontSize: 12, color: Color(0xFFB45309), height: 1.4),
      ),
    );
  }
}

