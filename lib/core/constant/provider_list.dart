// lib/core/constant/provider_list.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:provider_todo/core/di/injection_container.dart';
import 'package:provider_todo/core/theme/theme_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/oauth_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/auth_listener.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/forgot_password_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/otp_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/signin_provider.dart';
import 'package:provider_todo/features/auth/presentation/provider/parts/signup_provider.dart';
import 'package:provider_todo/features/todo/presentation/provider/todos_provider.dart';

class ProviderList {
  ProviderList._();

  static final List<SingleChildWidget> providers = [

    // ─── Theme ────────────────────────────────────────────
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => sl<ThemeProvider>(),
    ),

    // ─── Auth Base ────────────────────────────────────────
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => sl<AuthProvider>(),
    ),

    // ─── Auth Listener (session watcher) ──────────────────
    ChangeNotifierProvider<AuthListener>(
      create: (_) => sl<AuthListener>(),
    ),

    // ─── Sign In / Sign Out ───────────────────────────────
    ChangeNotifierProvider<SignInProvider>(
      create: (_) => sl<SignInProvider>(),
    ),

    // ─── Sign Up ──────────────────────────────────────────
    ChangeNotifierProvider<SignUpProvider>(
      create: (_) => sl<SignUpProvider>(),
    ),

    // ─── OTP Verification ─────────────────────────────────
    ChangeNotifierProvider<OtpProvider>(
      create: (_) => sl<OtpProvider>(),
    ),

    // ─── OAuth (Google, GitHub, Facebook) ─────────────────
    ChangeNotifierProvider<OAuthSignInProvider>(
      create: (_) => sl<OAuthSignInProvider>(),
    ),

    // ─── Forgot Password & Recovery ───────────────────────
    ChangeNotifierProvider<ForgotPasswordProvider>(
      create: (_) => sl<ForgotPasswordProvider>(),
    ),

    // ─── Todo ─────────────────────────────────────────────
    ChangeNotifierProvider<TodosProvider>(
      create: (_) => sl<TodosProvider>(),
    ),
  ];
}