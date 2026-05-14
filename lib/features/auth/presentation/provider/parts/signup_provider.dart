// lib/features/auth/presentation/provider/parts/signup_provider.dart
import 'package:flutter/material.dart';
import 'package:provider_todo/features/auth/presentation/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpProvider extends AuthProvider {
  SignUpProvider(super.client);

  String? _pendingFullName;
  String? _pendingPhone;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    setLoading();

    // ✅ Step 1 — Check if email already registered
    final emailExists = await _checkEmailExists(email);
    if (emailExists) {
      setError('An account with this email already exists. Please sign in.');
      debugPrint('❌ Signup blocked: email already registered → $email');
      return;
    }

    setOtpFlow(true);
    setEmail(email);
    setPhone(phone);
    _pendingFullName = fullName;
    _pendingPhone    = phone;

    await _sendSignupOtp(email);
  }

  // ✅ Check email before sending OTP
  Future<bool> _checkEmailExists(String email) async {
    try {
      final result = await client.rpc(
        'check_email_registered',
        params: {'email_to_check': email.toLowerCase().trim()},
      );
      debugPrint('📧 Signup email check → $email → exists: $result');
      return result as bool;
    } catch (e) {
      debugPrint('⚠️ Email check failed: $e');
      return false; // allow signup attempt if check fails
    }
  }

  Future<void> _sendSignupOtp(String email) async {
    try {
      await client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );
      setOtpSent();   // ✅ was notifyListeners() — now sets correct status
      debugPrint('📧 Signup OTP sent to: $email');
    } on AuthException catch (e) {
      setOtpFlow(false);
      debugPrint('❌ Signup OTP error: ${e.message}');
      setError(mapAuthError(e.message));
    }
  }

  Future<void> verifySignupOtp(String otp) async {
    setLoading();
    try {
      final response = await client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
      if (response.session == null) {
        setError('Verification failed');
        return;
      }
      await client.auth.updateUser(UserAttributes(data: {
        'full_name': _pendingFullName,
        'phone': _pendingPhone,
      }));
      setOtpFlow(false);
      setSuccess();
      printUserInfo(response.user);
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    }
  }
}