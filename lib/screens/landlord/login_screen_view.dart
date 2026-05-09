import 'package:flutter/material.dart';

import 'package:student_nest/core/constants/app_strings.dart';
import 'package:student_nest/core/widgets/sn_button.dart';
import 'register_screen.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_message_banner.dart';

class LoginScreenView extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final String? error;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onLoginPressed;

  const LoginScreenView({
    super.key,
    required this.phoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.error,
    required this.onTogglePasswordVisibility,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const AuthBrandHeader(
                title: 'Sign In',
                subtitle: 'Enter your phone number and password',
                showLogo: true,
                portalLabel: 'Landlord Portal',
              ),
              const SizedBox(height: 24),
              if (error != null) ...[
                AuthMessageBanner(
                  icon: Icons.error_outline,
                  color: theme.colorScheme.error,
                  message: error!,
                ),
                const SizedBox(height: 16),
              ],
              const AuthFieldLabel(label: 'Phone Number'),
              const SizedBox(height: 6),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '09XXXXXXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              const AuthFieldLabel(label: 'Password'),
              const SizedBox(height: 6),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: '********',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: onTogglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SNButton(
                label: AppStrings.signIn,
                onPressed: isLoading ? null : onLoginPressed,
                isLoading: isLoading,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Register',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
