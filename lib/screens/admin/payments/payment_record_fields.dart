import 'package:flutter/material.dart';

class PaymentLandlordDropdown extends StatelessWidget {
  final List<dynamic> landlords;
  final ValueChanged<String?> onChanged;

  const PaymentLandlordDropdown({
    super.key,
    required this.landlords,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Landlord'),
      items: landlords
          .where((landlord) => landlord['is_approved'] == true)
          .map(
            (landlord) => DropdownMenuItem<String>(
              value: landlord['id'] as String,
              child: Text(landlord['full_name'] ?? ''),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class PaymentPropertyDropdown extends StatelessWidget {
  final List<dynamic> properties;
  final String landlordId;
  final String? selectedPropertyId;
  final ValueChanged<String?> onChanged;

  const PaymentPropertyDropdown({
    super.key,
    required this.properties,
    required this.landlordId,
    required this.selectedPropertyId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedPropertyId,
      decoration: const InputDecoration(labelText: 'Property'),
      items: properties
          .where((property) => property['landlord_id'] == landlordId)
          .map(
            (property) => DropdownMenuItem<String>(
              value: property['id'] as String,
              child: Text(property['title'] ?? ''),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class PaymentPlanDropdown extends StatelessWidget {
  final String selectedPlan;
  final ValueChanged<String> onChanged;

  const PaymentPlanDropdown({
    super.key,
    required this.selectedPlan,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedPlan,
      decoration: const InputDecoration(labelText: 'Plan'),
      items: PaymentRecordDialogStateData.plans
          .map(
            (plan) => DropdownMenuItem<String>(
              value: plan,
              child: Text(
                '${plan[0].toUpperCase()}${plan.substring(1)} - K${plan == 'basic' ? '550' : '750'}/year',
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class PaymentDurationDropdown extends StatelessWidget {
  final String selectedDuration;
  final ValueChanged<String> onChanged;

  const PaymentDurationDropdown({
    super.key,
    required this.selectedDuration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedDuration,
      decoration: const InputDecoration(labelText: 'Duration (months)'),
      items: PaymentRecordDialogStateData.durations
          .map(
            (duration) => DropdownMenuItem<String>(
              value: duration,
              child: Text('$duration months'),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class PaymentMethodDropdown extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onChanged;

  const PaymentMethodDropdown({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedMethod,
      decoration: const InputDecoration(labelText: 'Payment Method'),
      items: PaymentRecordDialogStateData.methods
          .map(
            (method) => DropdownMenuItem<String>(
              value: method,
              child: Text(method.replaceAll('_', ' ').toUpperCase()),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class PaymentRecordDialogStateData {
  static const methods = ['airtel_money', 'mtn_money', 'bank_transfer', 'cash'];
  static const plans = ['basic', 'premium'];
  static const durations = ['6', '12'];
}
