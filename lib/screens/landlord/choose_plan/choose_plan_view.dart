import '../listing_payment/listing_payment_screen.dart';
import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import 'choose_plan_state.dart';
import 'widgets/plan_card.dart';
import 'widgets/plan_info_banner.dart';
import 'widgets/plan_summary_bar.dart';

class ChoosePlanView extends StatelessWidget {
  final ChoosePlanState state;

  const ChoosePlanView({super.key, required this.state});

  void _continue(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingPaymentScreen(selectedPlan: state.selectedPlan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(title: const Text('Choose Plan')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose your listing plan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pick the plan that fits how visible you want your property to be.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _cards(),
                    const SizedBox(height: 20),
                    PlanInfoBanner(isPremium: state.isPremium),
                  ],
                ),
              ),
            ),
            PlanSummaryBar(
              title: state.selectedTitle,
              price: state.selectedPrice,
              isPremium: state.isPremium,
              onContinue: () => _continue(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cards() {
    return Column(
      children: [
        PlanCard(
          title: 'Basic',
          price: 'K300',
          subtitle: 'Simple listing for landlords who want standard visibility',
          features: const [
            'Visible on boarding house listings',
            'Students can call and view details',
            'Standard placement in results',
          ],
          isSelected: state.isBasic,
          isRecommended: false,
          premium: false,
          onTap: () => state.selectPlan('basic'),
        ),
        const SizedBox(height: 16),
        PlanCard(
          title: 'Premium',
          price: 'K800',
          subtitle:
              'Best for landlords who want stronger visibility and more clicks',
          features: const [
            'Premium badge shown on your property',
            'Suggested higher on boarding house pages',
            'Better visibility for student discovery',
          ],
          isSelected: state.isPremium,
          isRecommended: true,
          premium: true,
          onTap: () => state.selectPlan('premium'),
        ),
      ],
    );
  }
}

