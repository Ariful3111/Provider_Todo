// lib/core/routes/app_router.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo/features/auth/presentation/pages/forgot_password.dart';
import 'package:provider_todo/features/auth/presentation/pages/new_password_page.dart';
import 'package:provider_todo/features/auth/presentation/pages/otp_page.dart';
import 'package:provider_todo/features/auth/presentation/pages/sign_in.dart';
import 'package:provider_todo/features/auth/presentation/pages/signup.dart';
import 'package:provider_todo/features/auth/presentation/pages/splash_screen.dart';
import 'package:provider_todo/features/profile/presentation/pages/my_profilepage.dart';
import 'package:provider_todo/features/todo/presentation/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider_todo/core/routes/app_routes.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';

// ✅ Listens to Supabase auth stream directly — independent of any provider
class _GoRouterRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _GoRouterRefreshNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      debugPrint('🔄 GoRouter: auth changed — refreshing redirect');
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final _refreshNotifier = _GoRouterRefreshNotifier();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _refreshNotifier, // ✅ fires on every auth event

    redirect: (BuildContext context, GoRouterState state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final loc = state.matchedLocation;

      // Read recovery flag safely
      bool isPasswordRecovery = false;
      try {
        isPasswordRecovery = context.read<AuthProvider>().isPasswordRecovery;
      } catch (_) {}

      // ── Recovery flow ────────────────────────────────────
      if (isLoggedIn && isPasswordRecovery && loc != AppRoutes.newPassword) {
        return AppRoutes.newPassword;
      }

      final authRoutes = [
        AppRoutes.splash,
        AppRoutes.signIn,
        AppRoutes.signUp,
        AppRoutes.forgotPassword,
        AppRoutes.otp,
      ];

      final isAuthRoute = authRoutes.contains(loc);
      final isProtectedRoute = !isAuthRoute && loc != AppRoutes.newPassword;

      // ── Not logged in on protected route → signIn ────────
      if (!isLoggedIn && isProtectedRoute) {
        debugPrint('🔒 Not logged in at $loc → signIn');
        return AppRoutes.signIn;
      }

      // ── Logged in on auth/splash route → home ────────────
      if (isLoggedIn && !isPasswordRecovery && isAuthRoute) {
        debugPrint('🏠 Logged in on auth route → home');
        return AppRoutes.home;
      }

      // ── newPassword only during recovery ─────────────────
      if (!isPasswordRecovery && loc == AppRoutes.newPassword) {
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
          // ✅ Correctly parse Map extra
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final type = extra['type'] as OtpType? ?? OtpType.email;
          final email = extra['email'] as String? ?? '';
          return OtpPage(otpType: type, email: email);
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
      GoRoute(
        path: AppRoutes.myProfile,
        builder: (context, state) => const MyProfilePage(),
      ),
    ],
  );
}
