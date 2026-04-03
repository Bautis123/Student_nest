import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _payments = [];
  List<dynamic> _landlords = [];
  List<dynamic> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final payments = await _api.getPayments();
      final landlords = await _api.getLandlords();
      final properties = await _api.getAdminProperties();
      setState(() {
        _payments = payments;
        _landlords = landlords as List;
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recordPayment() async {
    String? selectedLandlordId;
    String? selectedPropertyId;
    String selectedMethod = 'airtel_money';
    String selectedPlan = 'basic';
    String selectedDuration = '12';
    final referenceController = TextEditingController();
    final amountController = TextEditingController(text: '550');

    final methods = ['airtel_money', 'mtn_money', 'bank_transfer', 'cash'];
    final plans = ['basic', 'premium'];
    final durations = ['6', '12'];

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (ctx, setModalState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Record Payment'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Landlord',
                          ),
                          items:
                              _landlords
                                  .where((l) => l['is_approved'] == true)
                                  .map(
                                    (l) => DropdownMenuItem(
                                      value: l['id'] as String,
                                      child: Text(l['full_name'] ?? ''),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setModalState(() {
                                selectedLandlordId = v;
                                selectedPropertyId = null;
                              }),
                        ),
                        const SizedBox(height: 12),
                        if (selectedLandlordId != null)
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Property',
                            ),
                            items:
                                _properties
                                    .where(
                                      (p) =>
                                          p['landlord_id'] ==
                                          selectedLandlordId,
                                    )
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p['id'] as String,
                                        child: Text(p['title'] ?? ''),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) =>
                                    setModalState(() => selectedPropertyId = v),
                          ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedPlan,
                          decoration: const InputDecoration(labelText: 'Plan'),
                          items:
                              plans
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                        '${p[0].toUpperCase()}${p.substring(1)} — K${p == 'basic' ? '550' : '750'}/year',
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setModalState(() {
                                selectedPlan = v!;
                                amountController.text =
                                    v == 'basic' ? '550' : '750';
                              }),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedDuration,
                          decoration: const InputDecoration(
                            labelText: 'Duration (months)',
                          ),
                          items:
                              durations
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text('$d months'),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setModalState(() => selectedDuration = v!),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedMethod,
                          decoration: const InputDecoration(
                            labelText: 'Payment Method',
                          ),
                          items:
                              methods
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(
                                        m.replaceAll('_', ' ').toUpperCase(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setModalState(() => selectedMethod = v!),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: referenceController,
                          decoration: const InputDecoration(
                            labelText: 'Transaction Reference',
                            hintText: 'e.g. TXN123456',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount (K)',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedLandlordId == null ||
                            selectedPropertyId == null)
                          return;
                        Navigator.pop(ctx);
                        await _api.recordPayment({
                          'landlord_id': selectedLandlordId,
                          'property_id': selectedPropertyId,
                          'amount': double.parse(amountController.text),
                          'payment_method': selectedMethod,
                          'payment_reference': referenceController.text,
                          'duration_months': int.parse(selectedDuration),
                          'status': 'confirmed',
                        });
                        _loadData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment recorded successfully'),
                            ),
                          );
                        }
                      },
                      child: const Text('Record Payment'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmed =
        _payments.where((p) => p['status'] == 'confirmed').toList();
    final pending = _payments.where((p) => p['status'] == 'pending').toList();
    final totalRevenue = confirmed.fold(
      0.0,
      (sum, p) => sum + (p['amount'] as num).toDouble(),
    );

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            // Revenue summary
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Revenue',
                          style: TextStyle(fontSize: 12, color: AppTheme.gray),
                        ),
                        Text(
                          'K${totalRevenue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.success,
                          ),
                        ),
                        Text(
                          '${confirmed.length} confirmed · ${pending.length} pending',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _recordPayment,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Record'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Payment list
            Expanded(
              child:
                  _payments.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 48,
                              color: AppTheme.gray,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No payments yet',
                              style: TextStyle(
                                color: AppTheme.gray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tap Record to add a payment',
                              style: TextStyle(
                                color: AppTheme.gray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _payments.length,
                        itemBuilder: (_, i) {
                          final payment = _payments[i];
                          final isConfirmed = payment['status'] == 'confirmed';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        isConfirmed
                                            ? AppTheme.success.withOpacity(0.1)
                                            : AppTheme.warning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Icon(
                                    isConfirmed
                                        ? Icons.check_circle_outline
                                        : Icons.hourglass_empty_outlined,
                                    color:
                                        isConfirmed
                                            ? AppTheme.success
                                            : AppTheme.warning,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        payment['landlord_name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        payment['payment_method']
                                                ?.toString()
                                                .replaceAll('_', ' ')
                                                .toUpperCase() ??
                                            '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.gray,
                                        ),
                                      ),
                                      if (payment['payment_reference'] !=
                                              null &&
                                          payment['payment_reference']
                                              .toString()
                                              .isNotEmpty)
                                        Text(
                                          'Ref: ${payment['payment_reference']}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.gray,
                                          ),
                                        ),
                                      if (payment['expires_at'] != null)
                                        Text(
                                          'Expires: ${payment['expires_at'].toString().substring(0, 10)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.gray,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'K${(payment['amount'] as num).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isConfirmed
                                            ? AppTheme.success
                                            : AppTheme.warning,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        );
  }
}
