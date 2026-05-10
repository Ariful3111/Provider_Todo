// lib/core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/features/auth/presentation/pages/forgot_password.dart';
import 'package:provider_todo/features/auth/presentation/pages/new_password_page.dart';
import 'package:provider_todo/features/auth/presentation/pages/otp_page.dart';
import 'package:provider_todo/features/auth/presentation/pages/sign_in.dart';
import 'package:provider_todo/features/auth/presentation/pages/signup.dart';
import 'package:provider_todo/features/auth/presentation/pages/splash_screen.dart';
import 'package:provider_todo/features/todo/presentation/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
// ... other imports

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,

    redirect: (BuildContext context, GoRouterState state) {
      final session  = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final loc      = state.matchedLocation;

      // ✅ Safely read AuthProvider — may be null during startup
      AuthProvider? authProvider;
      try {
        authProvider = context.read<AuthProvider>();
      } catch (_) {}

      final isPasswordRecovery = authProvider?.isPasswordRecovery ?? false;

      // ─── Password Recovery Flow ──────────────────────────
      // ✅ User verified recovery OTP → must go to new password
      if (isLoggedIn && isPasswordRecovery) {
        if (loc != AppRoutes.newPassword) {
          debugPrint('🔑 Router: recovery session → redirecting to newPassword');
          return AppRoutes.newPassword;
        }
        return null; // already on new password page
      }

      // ─── Normal Auth Flow ────────────────────────────────
      final authRoutes = [
        AppRoutes.signIn,
        AppRoutes.signUp,
        AppRoutes.forgotPassword,
        AppRoutes.otp,
        AppRoutes.splash,
      ];

      // Logged in on auth/splash page → go home
      if (isLoggedIn && authRoutes.contains(loc)) {
        debugPrint('🏠 Router: logged in on auth route → home');
        return AppRoutes.home;
      }

      // Not logged in trying to access home → go sign in
      if (!isLoggedIn && loc == AppRoutes.home) {
        debugPrint('🔒 Router: not logged in → signIn');
        return AppRoutes.signIn;
      }

      // ✅ newPassword is only accessible during recovery
      if (!isPasswordRecovery && loc == AppRoutes.newPassword) {
        debugPrint('🔒 Router: no recovery session → signIn');
        return isLoggedIn ? AppRoutes.home : AppRoutes.signIn;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final type = state.extra as OtpType? ?? OtpType.email;
          return OtpPage(otpType: type);
        },
      ),
      GoRoute(
        path: AppRoutes.newPassword,
        builder: (context, state) => const NewPasswordView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Homepage(),
      ),
    ],
  );
}