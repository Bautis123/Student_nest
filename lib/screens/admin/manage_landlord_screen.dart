import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/theme.dart';
import 'manage_landlord/manage_landlord_app_bar.dart';
import 'manage_landlord/manage_landlord_details_section.dart';
import 'manage_landlord/manage_landlord_properties_section.dart';
import 'manage_landlord/manage_landlord_status_card.dart';
import 'manage_landlord/set_landlord_password_dialog.dart';

class ManageLandlordScreen extends StatefulWidget {
  final Map<String, dynamic> landlord;

  const ManageLandlordScreen({super.key, required this.landlord});

  @override
  State<ManageLandlordScreen> createState() => _ManageLandlordScreenState();
}

class _ManageLandlordScreenState extends State<ManageLandlordScreen> {
  final ApiService _api = ApiService();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  bool _isLoading = false;
  bool _hasChanges = false;
  List<dynamic> _properties = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.landlord['full_name'] ?? '',
    );
    _phoneController = TextEditingController(text: widget.landlord['phone'] ?? '');
    _emailController = TextEditingController(text: widget.landlord['email'] ?? '');
    _loadProperties();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    try {
      final all = await _api.getAdminProperties();
      if (!mounted) return;
      setState(() {
        _properties = all
            .where((p) => p['landlord_id'] == widget.landlord['id'])
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await _api.updateLandlordDetails(widget.landlord['id'], {
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      });
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Landlord updated successfully')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final newPassword = await showDialog<String>(
      context: context,
      builder: (_) => const SetLandlordPasswordDialog(),
    );
    if (newPassword == null || newPassword.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _api.resetLandlordPassword(widget.landlord['id'], newPassword);
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLandlord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        final name = widget.landlord['full_name'] ?? '';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Landlord'),
          content: Text(
            'Are you sure you want to delete $name? This will also delete all their listings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                minimumSize: const Size(80, 36),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _api.deleteLandlord(widget.landlord['id']);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Landlord deleted successfully')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleApproval() async {
    final isApproved = widget.landlord['is_approved'] == true;
    await _api.updateLandlordStatus(widget.landlord['id'], !isApproved);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isApproved ? 'Landlord suspended' : 'Landlord approved'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = widget.landlord['is_approved'] == true;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: ManageLandlordAppBar(
        isApproved: isApproved,
        onToggleApproval: _toggleApproval,
        onResetPassword: _sendPasswordReset,
        onDeleteLandlord: _deleteLandlord,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ManageLandlordStatusCard(
                    isApproved: isApproved,
                    propertyCount: _properties.length,
                  ),
                  const SizedBox(height: 16),
                  ManageLandlordDetailsSection(
                    nameController: _nameController,
                    phoneController: _phoneController,
                    emailController: _emailController,
                    hasChanges: _hasChanges,
                    isLoading: _isLoading,
                    onChanged: () => setState(() => _hasChanges = true),
                    onSave: _saveChanges,
                  ),
                  const SizedBox(height: 24),
                  ManageLandlordPropertiesSection(properties: _properties),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
