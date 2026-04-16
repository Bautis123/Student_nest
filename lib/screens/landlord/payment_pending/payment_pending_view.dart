import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../../../widgets/app_header_background.dart';
import '../payment_success/payment_success_screen.dart';
import 'payment_pending_state.dart';
import 'widgets/pending_actions_bar.dart';
import 'widgets/pending_status_card.dart';

class PaymentPendingView extends StatelessWidget {
  final PaymentPendingState state;

  const PaymentPendingView({super.key, required this.state});

  void _checkStatus(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => PaymentSuccessScreen(
              selectedPlan: state.selectedPlan,
              paymentMethod: state.paymentMethod,
            ),
      ),
    );
  }

  void _cancel(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Payment Pending'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: const AppHeaderBackground(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PendingStatusCard(
              isMobileMoney: state.isMobileMoney,
              planTitle: state.planTitle,
            ),
            const SizedBox(height: 16),
            PendingActionsBar(
              onCheckStatus: () => _checkStatus(context),
              onCancel: () => _cancel(context),
            ),
          ],
        ),
      ),
    );
  }
}

