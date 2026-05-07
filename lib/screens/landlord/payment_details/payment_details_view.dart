import 'package:flutter/material.dart';
import '../../../utils/app_design.dart';
import '../../../utils/theme.dart';
import '../../../widgets/app_surface_card.dart';
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
      backgroundColor: AppDesign.page(context),
      appBar: AppBar(
        title: const Text('Payment Details'),
        backgroundColor: AppDesign.surface(context),
        foregroundColor: AppDesign.text(context),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
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
                  _formCard(context),
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

  Widget _formCard(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.isMobileMoney ? 'Mobile money details' : 'Bank details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure the details match the account that will be billed.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: AppTheme.gray,
            ),
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

