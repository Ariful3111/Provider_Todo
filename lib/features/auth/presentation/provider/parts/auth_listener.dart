// lib/features/auth/presentation/provider/parts/auth_listener.dart
import 'package:flutter/material.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthListener extends AuthProvider {
  AuthListener(super.client) {
    client.auth.onAuthStateChange.listen((data) {
      final event   = data.event;
      final session = data.session;
      debugPrint('🔐 Auth event: $event');

      switch (event) {
        case AuthChangeEvent.passwordRecovery:
          setPasswordRecovery(true);
          setOtpFlow(false);
          setSuccess();
          debugPrint('🔑 Password recovery started');
          break;

        case AuthChangeEvent.signedIn:
          if (isInOtpFlow) {
            debugPrint('⏳ OTP flow — skipping');
            return;
          }
          setSuccess();
          printUserInfo(session?.user);
          debugPrint('✅ Signed in → router will redirect');
          break;

        case AuthChangeEvent.signedOut:
          clearAuthState();
          debugPrint('✅ Signed out → router will redirect');
          break;

        case AuthChangeEvent.userUpdated:
          setPasswordRecovery(false);
          setSuccess();
          break;

        case AuthChangeEvent.tokenRefreshed:
          setSuccess();
          break;

        default:
          break;
      }
      // ✅ NOTE: No need to call AppRouter.router.refresh() here
      // The _GoRouterRefreshNotifier in AppRouter listens to
      // the same stream and calls notifyListeners() automatically
    });
  }
}