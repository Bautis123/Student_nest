import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../payment_pending/payment_pending_screen.dart';
import 'payment_details_state.dart';
import 'widgets/bank_details_form.dart';
import 'widgets/mobile_money_form.dart';
import 'widgets/payment_continue_bar.dart';
import 'widgets/payment_details_header.dart';

class PaymentDetailsView extends StatelessWidget {
  final PaymentDetailsState state;

  const PaymentDetailsView({super.key, required this.state});

  void _continue(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PaymentPendingScreen(
              selectedPlan: state.selectedPlan,
              paymentMethod: state.paymentMethod,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Payment Details')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PaymentDetailsHeader(
                    amount: state.amount,
                    paymentLabel: state.paymentLabel,
                  ),
                  const SizedBox(height: 16),
                  _formCard(),
                ],
              ),
            ),
          ),
          PaymentContinueBar(
            enabled: state.canContinue,
            onContinue: () => _continue(context),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.isMobileMoney ? 'Mobile money details' : 'Bank details',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Make sure the details match the account that will be billed.',
            style: TextStyle(fontSize: 12, color: AppTheme.gray),
          ),
          const SizedBox(height: 16),
          state.isMobileMoney
              ? MobileMoneyForm(
                phoneController: state.phoneController,
                nameController: state.nameController,
                onChanged: state.refresh,
              )
              : BankDetailsForm(
                accountNameController: state.accountNameController,
                bankNameController: state.bankNameController,
                accountNumberController: state.accountNumberController,
                onChanged: state.refresh,
              ),
        ],
      ),
    );
  }
}
