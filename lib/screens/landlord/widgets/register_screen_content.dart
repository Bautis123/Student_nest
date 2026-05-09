import 'package:flutter/material.dart';

import 'package:student_nest/core/constants/app_strings.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/sn_button.dart';

class RegisterScreenContent extends StatelessWidget {
  const RegisterScreenContent({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.termsAccepted,
    required this.isLoading,
    required this.error,
    required this.success,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onTermsChanged,
    required this.onRegister,
    required this.onGoBack,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final bool termsAccepted;
  final bool isLoading;
  final String? error;
  final String? success;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onRegister;
  final VoidCallback onGoBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 190,
                height: 160,
                decoration: BoxDecoration(
                  color: AppDesign.accentTint(context),
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppDesign.accent,
                  size: 84,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 37,
                  fontWeight: FontWeight.w700,
                  color: AppDesign.text(context),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (success != null) ...[
              _InfoBanner(
                color: AppColors.success,
                icon: Icons.check_circle_outline,
                message: success!,
              ),
              const SizedBox(height: 12),
            ],
            if (error != null) ...[
              _InfoBanner(
                color: AppColors.error,
                icon: Icons.error_outline,
                message: error!,
              ),
              const SizedBox(height: 12),
            ],
            if (success == null) ...[
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
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
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: onToggleConfirm,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (v) => onTermsChanged(v ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'By registering, you are agreeing with our Terms of Use and Privacy Policy',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppDesign.text(context),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SNButton(
                label: AppStrings.register,
                onPressed: isLoading ? null : onRegister,
                isLoading: isLoading,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onGoBack,
                  child: Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: AppDesign.muted(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.color,
    required this.icon,
    required this.message,
  });

  final Color color;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
