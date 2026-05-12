// lib/features/auth/presentation/pages/sign_in_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/core/constant/app_colors.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/core/shared/extentions/validators/email_validator.dart';
import 'package:provider_todo/core/shared/extentions/validators/password_validator.dart';
import 'package:provider_todo/core/shared/widgets/app_primary_button.dart';
import 'package:provider_todo/core/shared/widgets/app_scaffold.dart';
import 'package:provider_todo/core/shared/widgets/app_text.dart';
import 'package:provider_todo/core/shared/widgets/app_text_field.dart';
import 'package:provider_todo/core/shared/widgets/social_login_button.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/oauth_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/signin_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final SignInProvider signInProvider;
  late final AuthProvider _authProvider;
  late final OAuthSignInProvider oAuthProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    signInProvider = context.read<SignInProvider>();
    oAuthProvider = context.read<OAuthSignInProvider>();
    _authProvider.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (!mounted) return;
    // ✅ Only show error snackbar — navigation handled by GoRouter redirect
    if (_authProvider.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.whiteText(
            _authProvider.errorMessage ?? 'Sign in failed',
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
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await signInProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Granular loading — each button knows its own state
    final bool isEmailLoading = auth.isEmailLoading;
    final bool isAnyLoading = auth.isEmailLoading || auth.isOAuthLoading;

    return AppScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _buildLogo(isDark),
              const SizedBox(height: 36),
              AppText.heading('Welcome back'),
              const SizedBox(height: 6),
              AppText(
                'Sign in to continue managing your todos',
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 14,
              ),
              const SizedBox(height: 32),

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

              // ── Password ──────────────────────────────────
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: '••••••••',
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

              // ── Forgot Password ───────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: AppText(
                    'Forgot Password?',
                    color: AppColors.primaryColor,
                  ),
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                ),
              ),

              // ── Sign In Button ────────────────────────────
              // ✅ Only loads when EMAIL sign in is in progress
              AppPrimaryButton(
                label: 'Sign In',
                isLoading: isEmailLoading,
                onPressed: isAnyLoading ? null : _signIn,
              ),
              const SizedBox(height: 24),

              _buildDivider(isDark),
              const SizedBox(height: 24),

              // ── Google ────────────────────────────────────
              // ✅ Each social button only shows loading for itself
              SocialLoginButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                iconColor: AppColors.googleColor,
                isLoading: auth.isProviderLoading(OAuthProvider.google),
                onPressed: isAnyLoading
                    ? null
                    : () => oAuthProvider.signInWithProvider(
                        OAuthProvider.google,
                      ),
              ),
              const SizedBox(height: 12),

              // ── Facebook ──────────────────────────────────
              SocialLoginButton(
                label: 'Continue with Facebook',
                icon: Icons.facebook_rounded,
                iconColor: AppColors.facebookColor,
                isLoading: auth.isProviderLoading(OAuthProvider.facebook),
                onPressed: isAnyLoading
                    ? null
                    : () => oAuthProvider.signInWithProvider(
                        OAuthProvider.facebook,
                      ),
              ),
              const SizedBox(height: 12),

              // ── GitHub ────────────────────────────────────
              SocialLoginButton(
                label: 'Continue with GitHub',
                icon: Icons.code_rounded,
                iconColor: isDark
                    ? AppColors.githubDark
                    : AppColors.githubColor,
                isLoading: auth.isProviderLoading(OAuthProvider.github),
                onPressed: isAnyLoading
                    ? null
                    : () => oAuthProvider.signInWithProvider(
                        OAuthProvider.github,
                      ),
              ),
              const SizedBox(height: 36),

              _buildSignUpRow(isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 10),
        AppText(
          'toDo',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    final dividerColor = isDark ? AppColors.borderDark : AppColors.dividerColor;
    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AppText(
            'or continue with',
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        Expanded(child: Divider(color: dividerColor)),
      ],
    );
  }

  Widget _buildSignUpRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          "Don't have an account? ",
          fontSize: 14,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.signUp),
          child: const AppText(
            'Sign Up',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
