import 'package:flutter/material.dart';

import '../../../utils/theme.dart';
import '../register_screen.dart';

class LoginScreenContent extends StatelessWidget {
  const LoginScreenContent({
    super.key,
    required this.phoneController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.error,
    required this.onTogglePassword,
    required this.onLogin,
  });

  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final String? error;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 190,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.meeting_room_outlined,
                  color: AppTheme.primary,
                  size: 82,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Center(
              child: Text(
                'Login',
                style: TextStyle(
                  color: AppTheme.dark,
                  fontSize: 46 / 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  error!,
                  style: const TextStyle(color: AppTheme.error, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'Username'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Forgot Password ?',
                    style: TextStyle(
                      color: AppTheme.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Create Account?',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              child:
                  isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text('Login'),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'Or Sign up With',
                style: TextStyle(
                  color: AppTheme.gray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialChip(iconData: Icons.g_mobiledata_rounded),
                SizedBox(width: 16),
                _SocialChip(iconData: Icons.facebook_rounded),
                SizedBox(width: 16),
                _SocialChip(iconData: Icons.apple_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.iconData});

  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Icon(iconData, color: AppTheme.dark, size: 28),
    );
  }
}
