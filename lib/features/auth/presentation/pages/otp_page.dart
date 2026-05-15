// lib/features/auth/presentation/pages/otp_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/shared/widgets/app_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/core/shared/widgets/app_primary_button.dart';
import 'package:provider_todo/core/shared/widgets/app_scaffold.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/otp_provider.dart';

class OtpPage extends StatefulWidget {
  final OtpType otpType;
  final String email; // ✅ received from GoRouter extra

  const OtpPage({super.key, required this.otpType, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _otpCode = '';

  bool get _isSignupOtp => widget.otpType == OtpType.email;
  bool get _isRecoveryOtp => widget.otpType == OtpType.recovery;

  @override
  void initState() {
    super.initState();
    // ✅ Set email on OtpProvider so verify calls use correct email
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OtpProvider>().setEmail(widget.email);
    });
  }

  void _submit() async {
    if (_otpCode.length < 6) {
      AppSnackbar().errorSnackBar(
        context: context,
        message: 'Please enter the complete 6-digit OTP',
      );
      return;
    }

    final otp = context.read<OtpProvider>();

    if (_isSignupOtp) {
      // ✅ Fixed: was calling verifyRecoveryOtp — now calls verifySignupOtp
      final response = await otp.verifySignupOtp(_otpCode);
      if (!mounted) return;
      if (response != null) {
        context.go(AppRoutes.home);
      } else {
        AppSnackbar().errorSnackBar(
          context: context,
          message: otp.errorMessage ?? 'Invalid OTP',
        );
      }
    } else if (_isRecoveryOtp) {
      await otp.verifyRecoveryOtp(_otpCode);
      if (!mounted) return;
      if (otp.status == AuthStatus.success) {
        context.go(AppRoutes.newPassword);
      } else {
        AppSnackbar().errorSnackBar(
          context: context,
          message: otp.errorMessage ?? 'Invalid OTP',
        );
      }
    }
  }

  void _resend() async {
    final otp = context.read<OtpProvider>();

    if (_isSignupOtp) {
      await otp.resendSignupOtp();
    } else {
      // ✅ For recovery resend, re-send reset password email
      await otp.sendRecoveryOtp(widget.email);
    }

    if (!mounted) return;
    if (otp.status == AuthStatus.success || otp.status == AuthStatus.otpSent) {
      AppSnackbar().successSnackbar(
        context: context,
        message: 'OTP resent to ${widget.email}',
      );
    } else {
      AppSnackbar().errorSnackBar(
        context: context,
        message: otp.errorMessage ?? 'Failed to resend OTP',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final TextStyle otpStyle =
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

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.primaryColor,
                size: 32,
              ),
            ),
            SizedBox(height: 24.h),

            AppText.heading('Verify your email'),
            SizedBox(height: 12.h),

            // ✅ Shows email from route — not from provider instance
            Wrap(
              children: [
                AppText(
                  'We sent a 6-digit code to ',
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                AppText(
                  widget.email, // ✅ from route extra, always correct
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

            OtpTextField(
              numberOfFields: 6,
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

            // ✅ Fixed: Consumer<OtpProvider> not Consumer<AuthProvider>
            Consumer<OtpProvider>(
              builder: (context, otp, _) => AppPrimaryButton(
                label: 'Verify',
                height: 48.h,
                isLoading: otp.isEmailLoading,
                onPressed: otp.isEmailLoading ? null : _submit,
              ),
            ),
            SizedBox(height: 20.h),

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
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
