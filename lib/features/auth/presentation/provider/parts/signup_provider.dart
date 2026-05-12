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

    setOtpFlow(true);

    setEmail(email);
    setPhone(phone);

    _pendingFullName = fullName;
    _pendingPhone = phone;

    await _sendSignupOtp(email);
  }

  Future<void> _sendSignupOtp(String email) async {
    try {
      await client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );

      notifyListeners();
    } on AuthException catch (e) {
      setOtpFlow(false);
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

      await client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _pendingFullName,
            'phone': _pendingPhone,
          },
        ),
      );

      setOtpFlow(false);

      setSuccess();

      printUserInfo(response.user);
    } on AuthException catch (e) {
      setError(mapAuthError(e.message));
    }
  }
}