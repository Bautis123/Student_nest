import 'package:flutter/material.dart';

class ChoosePlanState extends ChangeNotifier {
  String _selectedPlan = 'premium';

  String get selectedPlan => _selectedPlan;
  bool get isPremium => _selectedPlan == 'premium';
  bool get isBasic => _selectedPlan == 'basic';

  String get selectedPrice => isPremium ? 'K800 / year' : 'K300 / year';
  String get selectedTitle => isPremium ? 'Premium' : 'Basic';

  void selectPlan(String plan) {
    if (_selectedPlan == plan) return;
    _selectedPlan = plan;
    notifyListeners();
  }
}
