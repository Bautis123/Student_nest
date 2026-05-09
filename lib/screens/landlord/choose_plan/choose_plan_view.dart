import '../listing_payment/listing_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/features/landlord/widgets/plan_card.dart';
import 'choose_plan_state.dart';
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
      backgroundColor: AppDesign.page(context),
      appBar: AppBar(
        title: const Text('Choose Plan'),
        backgroundColor: AppDesign.surface(context),
        foregroundColor: AppDesign.text(context),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your listing plan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppDesign.text(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pick the plan that fits how visible you want your property to be.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppDesign.muted(context),
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
          plan: const ListingPlan(
            id: 'basic',
            title: 'Basic',
            price: 'K300',
            subtitle:
                'Simple listing for landlords who want standard visibility',
            features: [
              'Visible on boarding house listings',
              'Students can call and view details',
              'Standard placement in results',
            ],
          ),
          isSelected: state.isBasic,
          onTap: () => state.selectPlan('basic'),
        ),
        const SizedBox(height: 16),
        PlanCard(
          plan: const ListingPlan(
            id: 'premium',
            title: 'Premium',
            price: 'K800',
            subtitle:
                'Best for landlords who want stronger visibility and more clicks',
            features: [
              'Premium badge shown on your property',
              'Suggested higher on boarding house pages',
              'Better visibility for student discovery',
            ],
            isRecommended: true,
          ),
          isSelected: state.isPremium,
          onTap: () => state.selectPlan('premium'),
        ),
      ],
    );
  }
}
