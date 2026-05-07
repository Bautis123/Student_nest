import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_design.dart';
import '../landlord_main_screen.dart';
import 'widgets/login_screen_content.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _api = ApiService();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _login() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _api.login(
        _phoneController.text.trim(),
        _passwordController.text,
      );

      if (result['token'] != null) {
        await _api.saveToken(result['token']);
        await _api.saveUser(result['user']);

        if (mounted) {
          final role = result['user']['role'];
          if (role == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LandlordMainScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LandlordMainScreen()),
              (route) => false,
            );
          }
        }
      } else {
        setState(() => _error = result['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _error = 'Connection error. Check your network.');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.page(context),
      body: LoginScreenContent(
        phoneController: _phoneController,
        passwordController: _passwordController,
        isLoading: _isLoading,
        obscurePassword: _obscurePassword,
        error: _error,
        onTogglePassword: () {
          setState(() => _obscurePassword = !_obscurePassword);
        },
        onLogin: _login,
      ),
    );
  }
}
