import 'package:flutter/material.dart';

class PaymentRecordDialog extends StatefulWidget {
  final List<dynamic> landlords;
  final List<dynamic> properties;

  const PaymentRecordDialog({
    super.key,
    required this.landlords,
    required this.properties,
  });

  @override
  State<PaymentRecordDialog> createState() => _PaymentRecordDialogState();
}

class _PaymentRecordDialogState extends State<PaymentRecordDialog> {
  String? _selectedLandlordId;
  String? _selectedPropertyId;
  String _selectedMethod = 'airtel_money';
  String _selectedPlan = 'basic';
  String _selectedDuration = '12';
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController(text: '550');

  @override
  void dispose() {
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedLandlordId == null || _selectedPropertyId == null) return;

    Navigator.pop(context, {
      'landlord_id': _selectedLandlordId,
      'property_id': _selectedPropertyId,
      'amount': double.parse(_amountController.text),
      'payment_method': _selectedMethod,
      'payment_reference': _referenceController.text,
      'duration_months': int.parse(_selectedDuration),
      'status': 'confirmed',
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Record Payment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaymentLandlordDropdown(
              landlords: widget.landlords,
              onChanged: (value) {
                setState(() {
                  _selectedLandlordId = value;
                  _selectedPropertyId = null;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_selectedLandlordId != null)
              PaymentPropertyDropdown(
                properties: widget.properties,
                landlordId: _selectedLandlordId!,
                selectedPropertyId: _selectedPropertyId,
                onChanged:
                    (value) => setState(() => _selectedPropertyId = value),
              ),
            const SizedBox(height: 12),
            PaymentPlanDropdown(
              selectedPlan: _selectedPlan,
              onChanged: (value) {
                setState(() {
                  _selectedPlan = value;
                  _amountController.text = value == 'basic' ? '550' : '750';
                });
              },
            ),
            const SizedBox(height: 12),
            PaymentDurationDropdown(
              selectedDuration: _selectedDuration,
              onChanged: (value) => setState(() => _selectedDuration = value),
            ),
            const SizedBox(height: 12),
            PaymentMethodDropdown(
              selectedMethod: _selectedMethod,
              onChanged: (value) => setState(() => _selectedMethod = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Transaction Reference',
                hintText: 'e.g. TXN123456',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (K)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Record Payment')),
      ],
    );
  }
}

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
      items:
          landlords
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
      items:
          properties
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
      items:
          PaymentRecordDialogStateData.plans
              .map(
                (plan) => DropdownMenuItem<String>(
                  value: plan,
                  child: Text(
                    '${plan[0].toUpperCase()}${plan.substring(1)} • K${plan == 'basic' ? '550' : '750'}/year',
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
      items:
          PaymentRecordDialogStateData.durations
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
      items:
          PaymentRecordDialogStateData.methods
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
