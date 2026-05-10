// lib/features/auth/presentation/pages/sign_up_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/core/shared/extentions/validators/confirm_password_validator.dart';
import 'package:provider_todo/core/shared/extentions/validators/email_validator.dart';
import 'package:provider_todo/core/shared/extentions/validators/name_validator.dart';
import 'package:provider_todo/core/shared/extentions/validators/password_validator.dart';
import 'package:provider_todo/core/shared/widgets/app_primary_button.dart';
import 'package:provider_todo/core/shared/widgets/app_scaffold.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';
import 'package:provider_todo/core/shared/widgets/app_text_field.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  String _fullPhone = '';
  bool _phoneValid = false;

  AuthStatus? _lastHandledStatus;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final currentStatus = _authProvider.status;
    if (currentStatus == _lastHandledStatus) return;
    _lastHandledStatus = currentStatus;

    if (currentStatus == AuthStatus.otpSent) {
      final msg =
          '🎉 OTP sent to ${_authProvider.email}. Check your inbox!';
      debugPrint('✅ SNACKBAR: $msg');
      _showSuccessSnackbar(msg);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          // ✅ Pass OtpType.email — email OTP flow
          context.push(AppRoutes.otp, extra: OtpType.email);
        }
      });
    } else if (currentStatus == AuthStatus.error) {
      final msg = _authProvider.errorMessage ?? 'Sign up failed';
      debugPrint('❌ SNACKBAR ERROR: $msg');
      _showErrorSnackbar(msg);
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fullPhone.isEmpty || !_phoneValid) {
      _showErrorSnackbar('Please enter a valid phone number');
      return;
    }
    if (!_agreedToTerms) {
      _showErrorSnackbar('Please agree to the Terms & Privacy Policy');
      return;
    }
    _lastHandledStatus = null;
    await _authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      phone: _fullPhone,
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText.whiteText(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText.whiteText(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isLoading = auth.isEmailLoading;

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
              const SizedBox(height: 12),
              AppText.heading('Create account'),
              const SizedBox(height: 6),
              AppText(
                'Join us and start managing your tasks',
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 14,
              ),
              const SizedBox(height: 32),

              // ── Full Name ─────────────────────────────────
              AppTextField(
                controller: _nameController,
                label: 'Full name',
                hint: 'John Doe',
                validator: nameValidation,
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // ── Email ─────────────────────────────────────
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
              const SizedBox(height: 16),

              // ── Phone ─────────────────────────────────────
              IntlPhoneField(
                controller: _phoneController,
                initialCountryCode: 'BD',
                languageCode: 'en',
                disableLengthCheck: false,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  border: const OutlineInputBorder(),
                  counterText: '',
                  labelStyle: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                validator: (phone) {
                  if (phone == null || phone.number.isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
                onChanged: (PhoneNumber phone) {
                  _fullPhone = phone.completeNumber;
                  _phoneValid = true;
                },
                onCountryChanged: (_) {
                  _fullPhone = '';
                  _phoneValid = false;
                },
                invalidNumberMessage: 'Invalid phone number',
              ),
              const SizedBox(height: 16),

              // ── Password ──────────────────────────────────
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Min. 8 characters',
                obscureText: _obscurePassword,
                validator: passwordValidation,
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
              const SizedBox(height: 16),

              // ── Confirm Password ──────────────────────────
              AppTextField(
                controller: _confirmController,
                label: 'Confirm password',
                hint: '••••••••',
                obscureText: _obscureConfirm,
                validator: (val) =>
                    confirmPasswordValidation(_passwordController.text, val),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
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
              const SizedBox(height: 20),

              // ── Terms ─────────────────────────────────────
              _buildTermsRow(isDark),
              const SizedBox(height: 28),

              // ── Create Account Button ─────────────────────
              AppPrimaryButton(
                label: 'Create Account',
                isLoading: isLoading,
                onPressed: isLoading ? null : _signUp,
              ),
              const SizedBox(height: 28),

              _buildSignInRow(isDark),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsRow(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            children: [
              AppText('I agree to the ', fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              const AppText('Terms of Service', fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.primaryColor),
              AppText(' and ', fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              const AppText('Privacy Policy', fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.primaryColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText('Already have an account? ', fontSize: 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        GestureDetector(
          onTap: () => context.pop(),
          child: const AppText('Sign In', fontSize: 14,
              fontWeight: FontWeight.w600, color: AppColors.primaryColor),
        ),
      ],
    );
  }
}