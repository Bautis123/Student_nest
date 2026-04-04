class PaymentPendingState {
  final String selectedPlan;
  final String paymentMethod;

  PaymentPendingState({
    required this.selectedPlan,
    required this.paymentMethod,
  });

  bool get isMobileMoney => paymentMethod == 'mtn' || paymentMethod == 'airtel';
  String get planTitle => selectedPlan == 'premium' ? 'Premium' : 'Basic';
}
