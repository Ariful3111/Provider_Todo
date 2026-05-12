// // lib/features/auth/presentation/provider/parts/auth_signup_send.dart
// part of '../auth_provider.dart';

// extension _AuthSignUpSend on AuthProvider {

//   Future<void> signUp({
//     required String email,
//     required String password,
//     required String fullName,
//     required String phone,
//   }) async {
//     _setLoading();
//     _isInOtpFlow     = true;
//     _errorShown      = false;
//     _pendingEmail    = email;
//     _pendingPassword = password;
//     _pendingFullName = fullName;
//     _pendingPhone    = _phoneNumber = phone;
//     _email           = email;
//     await _sendEmailSignupOtp(email);
//   }

//   Future<void> _sendEmailSignupOtp(String email) async {
//     try {
//       await _client.auth.signInWithOtp(
//         email: email,
//         shouldCreateUser: true,
//         emailRedirectTo: null,
//       );
//       _status       = AuthStatus.otpSent;
//       _errorMessage = null;
//       _errorShown   = false;
//       notifyListeners();
//       debugPrint('📧 Signup OTP sent to: $email');
//     } on AuthException catch (e) {
//       _isInOtpFlow = false;
//       debugPrint('❌ Signup OTP error: ${e.message}');
//       _setError(_mapAuthError(e.message));
//     } catch (e) {
//       _isInOtpFlow = false;
//       _setError('Failed to send OTP. Please try again.');
//     }
//   }

//   Future<void> resendEmailOtp() async {
//     _setLoading();
//     _isInOtpFlow = true;
//     _errorShown  = false;
//     try {
//       await _client.auth.signInWithOtp(
//         email: _email,
//         shouldCreateUser: true,
//         emailRedirectTo: null,
//       );
//       _status       = AuthStatus.otpSent;
//       _errorMessage = null;
//       notifyListeners();
//       debugPrint('📧 OTP resent to: $_email');
//     } on AuthException catch (e) {
//       _isInOtpFlow = false;
//       _setError(_mapAuthError(e.message));
//     } catch (e) {
//       _isInOtpFlow = false;
//       _setError('Failed to resend OTP. Please try again.');
//     }
//   }
// }