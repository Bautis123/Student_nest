import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'payments/payment_record_dialog.dart';
import 'payments/payments_empty_state.dart';
import 'payments/payments_list.dart';
import 'payments/payments_summary_card.dart';

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
      if (!mounted) return;
      setState(() {
        _payments = payments;
        _landlords = landlords;
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recordPayment() async {
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => PaymentRecordDialog(
        landlords: _landlords,
        properties: _properties,
      ),
    );

    if (payload == null) return;

    await _api.recordPayment(payload);
    await _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment recorded successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmed = _payments.where((p) => p['status'] == 'confirmed').toList();
    final pending = _payments.where((p) => p['status'] == 'pending').toList();
    final totalRevenue = confirmed.fold<double>(
      0,
      (sum, p) => sum + (p['amount'] as num).toDouble(),
    );

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        PaymentsSummaryCard(
          totalRevenue: totalRevenue,
          confirmedCount: confirmed.length,
          pendingCount: pending.length,
          onRecordPressed: _recordPayment,
        ),
        const Divider(height: 1),
        Expanded(
          child: _payments.isEmpty
              ? const PaymentsEmptyState()
              : PaymentsList(payments: _payments),
        ),
      ],
    );
  }
}
