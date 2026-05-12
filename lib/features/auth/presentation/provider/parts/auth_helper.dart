// // lib/features/auth/presentation/provider/parts/auth_helpers.dart

// // ✅ ONLY this line at the top — zero import statements
// part of '../auth_provider.dart';

// extension _AuthHelpers on AuthProvider {

//   void _setLoading() {
//     _status = AuthStatus.loading;
//     _errorMessage = null;
//     _oauthProvider = null;
//     _errorShown = false;
//     notifyListeners();
//   }

//   void _setOAuthLoading(OAuthProvider provider) {
//     _status = AuthStatus.oauthLoading;
//     _oauthProvider = provider;
//     _errorMessage = null;
//     _errorShown = false;
//     notifyListeners();
//   }

//   void _setSuccess() {
//     _status = AuthStatus.success;
//     _oauthProvider = null;
//     _errorMessage = null;
//     _errorShown = false;
//     notifyListeners();
//   }

//   void _setError(String message) {
//     if (_errorShown) return;
//     _errorShown = true;
//     _status = AuthStatus.error;
//     _oauthProvider = null;
//     _errorMessage = message;
//     notifyListeners();
//   }

//   void _printUserInfo(User? user) {
//     if (user == null) return;
//     debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//     debugPrint('✅ USER SIGNED IN');
//     debugPrint('   ID       : ${user.id}');
//     debugPrint('   Email    : ${user.email ?? 'N/A'}');
//     debugPrint('   Name     : ${user.userMetadata?['full_name'] ?? 'N/A'}');
//     debugPrint('   Provider : ${user.appMetadata['provider'] ?? 'N/A'}');
//     debugPrint('   Verified : ${user.emailConfirmedAt != null}');
//     debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//   }

//   String _mapAuthError(String raw) {
//     final msg = raw.toLowerCase();
//     if (msg.contains('rate limit')) {
//       return 'Too many attempts. Please wait a few minutes.';
//     }
//     if (msg.contains('user already registered') ||
//         msg.contains('already been registered')) {
//       return 'An account with this email already exists.';
//     }
//     if (msg.contains('invalid login credentials') ||
//         msg.contains('invalid email or password')) {
//       return 'Incorrect email or password. Please try again.';
//     }
//     if (msg.contains('email not confirmed')) {
//       return 'Please verify your email before signing in.';
//     }
//     if (msg.contains('token has expired') || msg.contains('otp expired')) {
//       return 'The OTP has expired. Please request a new one.';
//     }
//     if (msg.contains('invalid otp') || msg.contains('token is invalid')) {
//       return 'Invalid OTP. Please check and try again.';
//     }
//     if (msg.contains('password') && msg.contains('short')) {
//       return 'Password must be at least 8 characters.';
//     }
//     if (msg.contains('network') || msg.contains('socket')) {
//       return 'Network error. Please check your connection.';
//     }
//     if (msg.contains('user not found')) {
//       return 'No account found with this email.';
//     }
//     return raw.isNotEmpty
//         ? '${raw[0].toUpperCase()}${raw.substring(1)}'
//         : 'Something went wrong. Please try again.';
//   }
// }