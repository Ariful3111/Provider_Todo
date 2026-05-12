// lib/features/auth/presentation/pages/new_password_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/core/shared/extentions/validators/confirm_password_validator.dart';
import 'package:provider_todo/core/shared/extentions/validators/password_validator.dart';
import 'package:provider_todo/core/shared/widgets/app_primary_button.dart';
import 'package:provider_todo/core/shared/widgets/app_scaffold.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';
import 'package:provider_todo/core/shared/widgets/app_text_field.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/forgot_password_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/signin_provider.dart';

class NewPasswordView extends StatefulWidget {
  const NewPasswordView({super.key});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  // ✅ FIX 1: formKey must be connected to a Form widget
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true; // ✅ FIX 2: separate bool for confirm field

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setPass() async {
    // ✅ FIX 1: validate() now works because Form widget wraps the fields
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<ForgotPasswordProvider>();
    await auth.updatePassword(_passwordController.text);

    if (!mounted) return;

    if (auth.status == AuthStatus.success) {
      // ✅ Show success snackbar before navigating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.whiteText('Password updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      context.go(AppRoutes.signIn);
    } else if (auth.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.whiteText(
            auth.errorMessage ?? 'Failed to update password',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return AppScaffold(
      // ✅ FIX 1: Wrap everything in Form — this is what was missing
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),

              // ── Icon ──────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primaryColor,
                  size: 32,
                ),
              ),
              SizedBox(height: 24.h),

              AppText.heading('Set New Password'),
              SizedBox(height: 8.h),
              AppText(
                'Must be at least 8 characters',
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              SizedBox(height: 28.h),

              // ── New Password ──────────────────────────────
              AppTextField(
                controller: _passwordController,
                label: 'New Password',
                hint: '••••••••',
                obscureText: _obscurePassword,
                validator: passwordValidation, // ✅ runs because Form wraps it
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              SizedBox(height: 20.h),

              // ── Confirm Password ──────────────────────────
              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: '••••••••',
                obscureText: _obscureConfirm, // ✅ FIX 2: uses _obscureConfirm
                validator: (val) => confirmPasswordValidation(
                  _passwordController.text,
                  val,
                ), // ✅ shows mismatch error because Form wraps it
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm // ✅ FIX 2: was using _obscurePassword by mistake
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              SizedBox(height: 28.h),

              // ── Continue Button ───────────────────────────
              AppPrimaryButton(
                height: 48.h,
                label: 'Continue',
                isLoading: auth.status == AuthStatus.loading,
                onPressed: auth.status == AuthStatus.loading ? null : _setPass,
              ),
              SizedBox(height: 20.h),

              // ── Back to login ─────────────────────────────
              InkWell(
                onTap: () =>  context.read<SignInProvider>().signOut(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 20.sp,
                        color: isDark
                            ? AppColors.whiteColor
                            : AppColors.borderDark,
                      ),
                      SizedBox(width: 8.w),
                      AppText(
                        'Back to log in',
                        fontSize: 16.sp,
                        color: isDark
                            ? AppColors.whiteColor
                            : AppColors.borderDark,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
