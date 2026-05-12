import 'package:flutter/material.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInProvider extends AuthProvider {
  SignInProvider(super.client);

  Future<void> signIn({required String email, required String password}) async {
    setLoading();

    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        setSuccess();
        printUserInfo(response.user);
      } else {
        setError('Login failed');
      }
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    } catch (e) {
      setError('Unexpected error');
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();

      clearAuthState();

      debugPrint('✅ User signed out');
    } on AuthException catch (e) {
      debugPrint('❌ SignOut error: ${e.message}');
      setError(mapAuthError(e.message));
    } catch (e) {
      debugPrint('❌ SignOut unknown error: $e');
      setError('Failed to sign out');
    }
  }
}
