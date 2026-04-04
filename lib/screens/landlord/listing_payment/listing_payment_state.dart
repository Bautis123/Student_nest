import 'package:flutter/material.dart';

class ListingPaymentState extends ChangeNotifier {
  final String selectedPlan;
  String _paymentMethod = 'mtn';

  ListingPaymentState({required this.selectedPlan});

  bool get isPremium => selectedPlan == 'premium';
  String get planTitle => isPremium ? 'Premium' : 'Basic';
  String get amount => isPremium ? 'K800' : 'K300';
  String get paymentMethod => _paymentMethod;

  void selectMethod(String method) {
    if (_paymentMethod == method) return;
    _paymentMethod = method;
    notifyListeners();
  }
}
