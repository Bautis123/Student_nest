import 'package:flutter/material.dart';

class PaymentDetailsState extends ChangeNotifier {
  final String selectedPlan;
  final String paymentMethod;

  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final accountNameController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();

  PaymentDetailsState({
    required this.selectedPlan,
    required this.paymentMethod,
  });

  bool get isPremium => selectedPlan == 'premium';
  bool get isMobileMoney => paymentMethod == 'mtn' || paymentMethod == 'airtel';
  String get amount => isPremium ? 'K800' : 'K300';

  String get paymentLabel {
    switch (paymentMethod) {
      case 'airtel':
        return 'Airtel Money';
      case 'card':
        return 'Bank Payment';
      default:
        return 'MTN Mobile Money';
    }
  }

  bool get canContinue {
    if (isMobileMoney) {
      return phoneController.text.trim().isNotEmpty &&
          nameController.text.trim().isNotEmpty;
    }

    return accountNameController.text.trim().isNotEmpty &&
        bankNameController.text.trim().isNotEmpty &&
        accountNumberController.text.trim().isNotEmpty;
  }

  void refresh() => notifyListeners();

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    accountNameController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    super.dispose();
  }
}
