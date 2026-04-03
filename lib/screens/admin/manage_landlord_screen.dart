import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';

class ManageLandlordScreen extends StatefulWidget {
  final Map<String, dynamic> landlord;

  const ManageLandlordScreen({super.key, required this.landlord});

  @override
  State<ManageLandlordScreen> createState() => _ManageLandlordScreenState();
}

class _ManageLandlordScreenState extends State<ManageLandlordScreen> {
  final ApiService _api = ApiService();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  bool _hasChanges = false;
  List<dynamic> _properties = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.landlord['full_name'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.landlord['phone'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.landlord['email'] ?? '',
    );
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      final all = await _api.getAdminProperties();
      setState(() {
        _properties =
            (all as List)
                .where((p) => p['landlord_id'] == widget.landlord['id'])
                .toList();
      });
    } catch (e) {}
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await _api.updateLandlordDetails(widget.landlord['id'], {
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      });
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Landlord updated successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final newPassword = await showDialog<String>(
      context: context,
      builder: (_) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Set New Password'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter new password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Set Password'),
            ),
          ],
        );
      },
    );

    if (newPassword == null || newPassword.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _api.resetLandlordPassword(widget.landlord['id'], newPassword);
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLandlord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Landlord'),
            content: Text(
              'Are you sure you want to delete ${widget.landlord['full_name']}? This will also delete all their listings.',
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
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _api.deleteLandlord(widget.landlord['id']);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Landlord deleted successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleApproval() async {
    final isApproved = widget.landlord['is_approved'] == true;
    await _api.updateLandlordStatus(widget.landlord['id'], !isApproved);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApproved ? 'Landlord suspended' : 'Landlord approved',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = widget.landlord['is_approved'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manage Landlord'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder:
                (_) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          isApproved
                              ? Icons.block_outlined
                              : Icons.check_circle_outline,
                          size: 18,
                          color:
                              isApproved ? AppTheme.warning : AppTheme.success,
                        ),
                        const SizedBox(width: 10),
                        Text(isApproved ? 'Suspend' : 'Approve'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Reset Password'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppTheme.error,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Delete Landlord',
                          style: TextStyle(color: AppTheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              if (value == 'toggle') _toggleApproval();
              if (value == 'reset') _sendPasswordReset();
              if (value == 'delete') _deleteLandlord();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color:
                                  isApproved
                                      ? AppTheme.success
                                      : AppTheme.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isApproved ? 'Active account' : 'Pending approval',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  isApproved
                                      ? AppTheme.success
                                      : AppTheme.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_properties.length} listing${_properties.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Edit details
                    const Text(
                      'Landlord Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _fieldLabel('Full Name'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() => _hasChanges = true),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _fieldLabel('Phone Number'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() => _hasChanges = true),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _fieldLabel('Email'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() => _hasChanges = true),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_hasChanges)
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        child: const Text('Save Changes'),
                      ),

                    const SizedBox(height: 24),

                    // Listings
                    const Text(
                      'Listings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_properties.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Text(
                            'No listings yet',
                            style: TextStyle(color: AppTheme.gray),
                          ),
                        ),
                      )
                    else
                      ...(_properties.map(
                        (p) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.home_work_outlined,
                                  color: AppTheme.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['title'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      p['address'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.gray,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      p['is_approved'] == true
                                          ? AppTheme.success.withOpacity(0.1)
                                          : AppTheme.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  p['is_approved'] == true ? 'Live' : 'Pending',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        p['is_approved'] == true
                                            ? AppTheme.success
                                            : AppTheme.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppTheme.dark,
    ),
  );
}
