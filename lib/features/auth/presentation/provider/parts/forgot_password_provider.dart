import 'package:flutter/material.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordProvider extends AuthProvider {
  ForgotPasswordProvider(super.client);

  Future<void> sendPasswordResetOtp(
    String email,
  ) async {
    setLoading();

    setEmail(email);

    try {
      await client.auth.resetPasswordForEmail(email);

      setSuccess();
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    }
  }

  Future<void> verifyRecoveryOtp(String otp) async {
    setLoading();

    try {
      final response = await client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );

      if (response.session != null) {
        setPasswordRecovery(true);
        setSuccess();
      } else {
        setError('Verification failed');
      }
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    }
  }

  Future<void> updatePassword(
    String password,
  ) async {
    setLoading();

    try {
      await client.auth.updateUser(
        UserAttributes(password: password),
      );

      setPasswordRecovery(false);

      setSuccess();
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    }
  }
  Future<bool> checkEmailRegistered(String email) async {
    try {
      final result = await client.rpc(
        'check_email_registered',
        params: {'email_to_check': email.toLowerCase().trim()},
      );
      debugPrint('📧 Email check → $email → exists: $result');
      return result as bool;
    } catch (e) {
      debugPrint('❌ Email check error: $e');
      return false; // assume not found on error
    }
  }
}