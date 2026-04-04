class PaymentSuccessState {
  final String selectedPlan;
  final String paymentMethod;

  PaymentSuccessState({
    required this.selectedPlan,
    required this.paymentMethod,
  });

  bool get isPremium => selectedPlan == 'premium';
  String get planTitle => isPremium ? 'Premium' : 'Basic';
  String get amount => isPremium ? 'K800' : 'K300';
  String get nextExpiry => 'Nov 12, 2026';

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'airtel':
        return 'Airtel Money';
      case 'card':
        return 'Bank Card';
      default:
        return 'MTN Mobile Money';
    }
  }
}
