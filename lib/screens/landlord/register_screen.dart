import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'widgets/register_screen_content.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _api = ApiService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _termsAccepted = true;
  String? _error;
  String? _success;

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _error = 'Please fill in all required fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    if (!_termsAccepted) {
      setState(() => _error = 'Please agree to the terms before registering');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final result = await _api.register(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        _passwordController.text,
      );

      if (result['user'] != null) {
        setState(() {
          _success =
              'Registration successful! Your account is pending admin approval.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Registration failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error. Check your network.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.page(context),
      body: RegisterScreenContent(
        nameController: _nameController,
        phoneController: _phoneController,
        emailController: _emailController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        obscurePassword: _obscurePassword,
        obscureConfirm: _obscureConfirm,
        termsAccepted: _termsAccepted,
        isLoading: _isLoading,
        error: _error,
        success: _success,
        onTogglePassword: () {
          setState(() => _obscurePassword = !_obscurePassword);
        },
        onToggleConfirm: () {
          setState(() => _obscureConfirm = !_obscureConfirm);
        },
        onTermsChanged: (value) {
          setState(() => _termsAccepted = value);
        },
        onRegister: _register,
        onGoBack: () => Navigator.pop(context),
      ),
    );
  }
}
