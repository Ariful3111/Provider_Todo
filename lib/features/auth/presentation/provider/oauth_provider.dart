import 'auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthSignInProvider extends AuthProvider {
  OAuthSignInProvider(super.client);

  Future<void> signInWithProvider(
    OAuthProvider provider,
  ) async {
    setOAuthLoading(provider);

    try {
      await client.auth.signInWithOAuth(
        provider,
        redirectTo:
            'io.supabase.flutter://login-callback',
      );

      resetStatus();
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    }
  }
}