import 'package:flutter/material.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class OtpProvider extends AuthProvider {
  OtpProvider(super.client);

  // ─────────────────────────────────────
  // Send Signup OTP
  // ─────────────────────────────────────
  Future<void> sendSignupOtp(String email) async {
    setLoading();

    try {
      await client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );

      setOtpFlow(true);

      setSuccess();

      debugPrint('📧 Signup OTP sent');
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    }
  }

  // ─────────────────────────────────────
  // Resend Signup OTP
  // ─────────────────────────────────────
  Future<void> resendSignupOtp() async {
    setLoading();

    try {
      await client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );

      setSuccess();

      debugPrint('📧 Signup OTP resent');
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    }
  }

  // ─────────────────────────────────────
  // Verify Signup OTP
  // ─────────────────────────────────────
  Future<AuthResponse?> verifySignupOtp(
    String otp,
  ) async {
    setLoading();

    try {
      final response = await client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (response.session == null) {
        setError('Verification failed');
        return null;
      }

      setOtpFlow(false);

      setSuccess();

      debugPrint('✅ Signup OTP verified');

      return response;
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
      return null;
    }
  }

  // ─────────────────────────────────────
  // Send Recovery OTP
  // ─────────────────────────────────────
  Future<void> sendRecoveryOtp(
    String email,
  ) async {
    setLoading();

    setEmail(email);

    try {
      await client.auth.resetPasswordForEmail(
        email,
      );

      setOtpFlow(true);

      setSuccess();

      debugPrint('📧 Recovery OTP sent');
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    }
  }

  // ─────────────────────────────────────
  // Verify Recovery OTP
  // ─────────────────────────────────────
  Future<void> verifyRecoveryOtp(
    String otp,
  ) async {
    setLoading();

    try {
      final response = await client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );

      if (response.session != null) {
        setPasswordRecovery(true);

        setOtpFlow(false);

        setSuccess();

        debugPrint('✅ Recovery OTP verified');
      } else {
        setError('Verification failed');
      }
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    }
  }
}