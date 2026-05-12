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
  static List<SingleChildWidget> providers = [

    // ─────────────────────────────────────
    // Todo
    // ─────────────────────────────────────
    ChangeNotifierProvider(
      create: (_) => sl<TodosProvider>(),
    ),

    // ─────────────────────────────────────
    // Base Auth
    // ─────────────────────────────────────
    ChangeNotifierProvider(
      create: (_) => sl<AuthProvider>(),
    ),

    // ─────────────────────────────────────
    // Sign In
    // ─────────────────────────────────────
    ChangeNotifierProvider(
      create: (_) => sl<SignInProvider>(),
    ),

    // ─────────────────────────────────────
    // Sign Up
    // ─────────────────────────────────────
    ChangeNotifierProvider(
      create: (_) => sl<SignUpProvider>(),
    ),

    // ─────────────────────────────────────
    // OTP
    // ─────────────────────────────────────
    ChangeNotifierProvider(
      create: (_) => sl<OtpProvider>(),
    ),

    // ─────────────────────────────────────
    // OAuth
    // ─────────────────────────────────────
    ChangeNotifierProvider(
      create: (_) => sl<OAuthSignInProvider>(),
    ),

    // ─────────────────────────────────────
    // Password Recovery
    // ─────────────────────────────────────
    ChangeNotifierProvider(
      create: (_) => sl<ForgotPasswordProvider>(),
    ),

    // ─────────────────────────────────────
    // Session
    // ─────────────────────────────────────
    ChangeNotifierProvider(
      create: (_) => sl<AuthListener>(),
    ),

    // ─────────────────────────────────────
    // Theme
    // ─────────────────────────────────────
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
    ),
  ];
}