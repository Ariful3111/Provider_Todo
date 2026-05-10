// lib/features/auth/presentation/pages/otp_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/core/shared/widgets/app_primary_button.dart';
import 'package:provider_todo/core/shared/widgets/app_scaffold.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';

class OtpPage extends StatefulWidget {
  final OtpType otpType;
  const OtpPage({super.key, required this.otpType});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _otpCode = '';

  // ✅ true = signup email OTP, false = forgot password recovery OTP
  bool get _isSignupOtp => widget.otpType == OtpType.email;
  bool get _isRecoveryOtp => widget.otpType == OtpType.recovery;

  void _submit() async {
    if (_otpCode.length < 6) {
      _showSnackbar('Please enter the complete 6-digit OTP');
      return;
    }

    final auth = context.read<AuthProvider>();

    if (_isSignupOtp) {
      // ✅ Email OTP for signup verification
      await auth.verifyEmailSignupOtp(_otpCode);
      if (!mounted) return;
      if (auth.status == AuthStatus.success) {
        context.go(AppRoutes.home);
      } else if (auth.status == AuthStatus.error) {
        _showSnackbar(auth.errorMessage ?? 'Invalid OTP');
      }
    } else if (_isRecoveryOtp) {
      // ✅ Recovery OTP for forgot password
      await auth.verifyEmailOtp(_otpCode);
      if (!mounted) return;
      if (auth.status == AuthStatus.success) {
        context.go(AppRoutes.newPassword);
      } else if (auth.status == AuthStatus.error) {
        _showSnackbar(auth.errorMessage ?? 'Invalid OTP');
      }
    }
  }

  void _resend() async {
    final auth = context.read<AuthProvider>();
    if (_isSignupOtp) {
      await auth.resendEmailOtp();
    } else {
      await auth.resendEmailOtp();
    }
    if (!mounted) return;
    if (auth.status == AuthStatus.otpSent) {
      _showSuccessSnackbar('OTP resent successfully');
    } else if (auth.status == AuthStatus.error) {
      _showSnackbar(auth.errorMessage ?? 'Failed to resend OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    // ✅ Show email for all OTP types
    final destination = auth.email;

    TextStyle otpStyle =
        (Theme.of(context).textTheme.headlineMedium ?? GoogleFonts.rubik())
            .copyWith(
              color: isDark ? AppColors.whiteColor : AppColors.primaryColor,
            );

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // ── Icon ──────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.mark_email_read_outlined, // ✅ always email icon
                color: AppColors.primaryColor,
                size: 32,
              ),
            ),
            SizedBox(height: 24.h),

            // ── Title ─────────────────────────────────────
            AppText.heading('Verify your email'),
            SizedBox(height: 12.h),

            // ── Subtitle ──────────────────────────────────
            Wrap(
              children: [
                AppText(
                  'We sent a 6-digit verification code to ',
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                AppText(
                  destination,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            AppText(
              'Check your inbox and spam folder.',
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            SizedBox(height: 48.h),

            // ── OTP Field — 6 digits ──────────────────────
            OtpTextField(
              numberOfFields: 6, // ✅ matches Supabase setting
              borderColor: isDark
                  ? AppColors.whiteColor
                  : AppColors.primaryColor,
              focusedBorderColor: isDark
                  ? AppColors.whiteColor
                  : AppColors.primaryColor,
              borderWidth: 2.r,
              contentPadding: EdgeInsets.all(2.r),
              keyboardType: const TextInputType.numberWithOptions(),
              styles: List.filled(6, otpStyle),
              cursorColor: isDark ? AppColors.whiteColor : null,
              onCodeChanged: (value) => _otpCode = value,
              onSubmit: (value) {
                _otpCode = value;
                _submit();
              },
            ),
            SizedBox(height: 40.h),

            // ── Verify Button ─────────────────────────────
            Consumer<AuthProvider>(
              builder: (context, auth, _) => AppPrimaryButton(
                label: 'Verify',
                height: 48.h,
                isLoading: auth.status == AuthStatus.loading,
                onPressed: auth.status == AuthStatus.loading ? null : _submit,
              ),
            ),
            SizedBox(height: 20.h),

            // ── Resend ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  "Didn't receive it? ",
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                GestureDetector(
                  onTap: _resend,
                  child: const AppText(
                    'Resend OTP',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText.whiteText(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
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
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }
}
