import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthListener extends AuthProvider {
  AuthListener(super.client) {
    client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      switch (event) {
        case AuthChangeEvent.signedIn:
          setSuccess();
          break;

        case AuthChangeEvent.signedOut:
          resetStatus();
          break;

        default:
          break;
      }
    });
  }
}