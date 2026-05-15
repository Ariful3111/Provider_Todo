// lib/features/auth/presentation/pages/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/shared/widgets/app_snackbar.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/forgot_password_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/core/shared/extentions/validators/email_validator.dart';
import 'package:provider_todo/core/shared/widgets/app_primary_button.dart';
import 'package:provider_todo/core/shared/widgets/app_scaffold.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';
import 'package:provider_todo/core/shared/widgets/app_text_field.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<ForgotPasswordProvider>();
    final email = _emailController.text.trim();

    // ✅ Step 1 — Check if email is registered
    final exists = await auth.checkEmailRegistered(email);

    if (!mounted) return;

    if (!exists) {
      // ✅ Email not found — show error
      debugPrint('❌ Forgot password: email not registered → $email');
      AppSnackbar().errorSnackBar(
        context: context,
        message: 'No account found with this email address.',
      );
      return;
    }

    // ✅ Step 2 — Email exists — send OTP
    debugPrint('✅ Forgot password: email registered → $email, sending OTP...');
    await auth.sendPasswordResetOtp(email);

    if (!mounted) return;

    if (auth.status == AuthStatus.otpSent) {
      debugPrint('✅ Forgot password OTP sent to: $email');
      AppSnackbar().successSnackbar(
        context: context,
        message: 'OTP sent to $email',
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) context.push(AppRoutes.otp, extra: OtpType.recovery);
      });
    } else if (auth.status == AuthStatus.error) {
      debugPrint('❌ Forgot password OTP error: ${auth.errorMessage}');
      AppSnackbar().errorSnackBar(
        message: auth.errorMessage ?? 'Failed to send OTP',
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return AppScaffold(
      appbar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),

              AppText.heading('Forgot password?'),
              const SizedBox(height: 8),
              AppText(
                'Enter your registered email. We\'ll send you a 6-digit OTP.',
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 14,
              ),
              const SizedBox(height: 32),

              AppTextField(
                controller: _emailController,
                label: 'Email address',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: emailValidation,
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // ✅ Button renamed to "Send OTP"
              AppPrimaryButton(
                label: 'Send OTP',
                isLoading: auth.isEmailLoading,
                onPressed: auth.isEmailLoading ? null : _sendOtp,
              ),
              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      const AppText(
                        'Back to Sign In',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ],
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
