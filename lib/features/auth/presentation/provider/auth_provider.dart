// lib/features/auth/presentation/provider/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:provider_todo/core/routes/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { idle, loading, oauthLoading, success, otpSent, error }

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client;
  bool _isInOtpFlow = false;
  bool _errorShown = false;

  // Pending signup data
  String? _pendingEmail;
  String? _pendingPassword;
  String? _pendingFullName;
  String? _pendingPhone;

  // lib/features/auth/presentation/provider/auth_provider.dart

// Add this field
bool _isPasswordRecovery = false;
bool get isPasswordRecovery => _isPasswordRecovery;

// ─── Update onAuthStateChange listener ───────────────────
AuthProvider(this._client) {
  _client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final session = data.session;
    debugPrint('🔐 Auth event: $event');

    switch (event) {

      // ✅ ADD THIS CASE — fires when recovery OTP is verified
      case AuthChangeEvent.passwordRecovery:
        _isPasswordRecovery = true;
        _isInOtpFlow = false;
        debugPrint('🔑 Password recovery session started');
        _setSuccess();
        AppRouter.router.refresh();  // triggers GoRouter redirect
        break;

      case AuthChangeEvent.signedIn:
        if (_isInOtpFlow) {
          debugPrint('⏳ OTP flow active — skipping router refresh');
          return;
        }
        if (_isPasswordRecovery) {
          // ✅ Don't navigate to home during recovery — GoRouter handles it
          debugPrint('🔑 Recovery sign-in — letting router redirect to newPassword');
          _setSuccess();
          AppRouter.router.refresh();
          return;
        }
        _setSuccess();
        _printUserInfo(session?.user);
        Future.delayed(const Duration(milliseconds: 300), () {
          AppRouter.router.refresh();
        });
        break;

      case AuthChangeEvent.signedOut:
        _isInOtpFlow = false;
        _isPasswordRecovery = false;   // ✅ reset flag
        _status = AuthStatus.idle;
        _oauthProvider = null;
        _errorMessage = null;
        _errorShown = false;
        notifyListeners();
        AppRouter.router.refresh();
        break;

      case AuthChangeEvent.userUpdated:
        _isPasswordRecovery = false;   // ✅ reset after password updated
        _setSuccess();
        break;

      case AuthChangeEvent.tokenRefreshed:
        _setSuccess();
        break;

      default:
        break;
    }
  });
}

// ─── Update updatePassword() — reset flag after success ──
Future<void> updatePassword(String newPassword) async {
  _setLoading();
  _errorShown = false;
  try {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    _isPasswordRecovery = false;    // ✅ clear flag after password set
    _setSuccess();
    debugPrint('✅ Password updated successfully');
  } on AuthException catch (e) {
    debugPrint('❌ Update password error: ${e.message}');
    _setError(_mapAuthError(e.message));
  } catch (e) {
    debugPrint('❌ Update password unknown: $e');
    _setError('Failed to update password');
  }
}

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  String _phoneNumber = '';
  String _email = '';
  OAuthProvider? _oauthProvider;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get phoneNumber => _phoneNumber;
  String get email => _email;

  bool get isEmailLoading => _status == AuthStatus.loading;
  bool get isOAuthLoading => _status == AuthStatus.oauthLoading;
  OAuthProvider? get loadingOAuthProvider => _oauthProvider;
  bool isProviderLoading(OAuthProvider provider) =>
      isOAuthLoading && _oauthProvider == provider;

  // ─── Step 1: Store data + send email OTP ──────────────────
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    _setLoading();
    _isInOtpFlow = true;
    _errorShown = false;

    // Store pending data — account created after OTP verified
    _pendingEmail = email;
    _pendingPassword = password;
    _pendingFullName = fullName;
    _pendingPhone = phone;
    _phoneNumber = phone;
    _email = email;

    // ✅ Send email OTP — no SMS provider needed
    await _sendEmailSignupOtp(email);
  }

  // ─── Send email OTP for signup ────────────────────────────
  // ✅ This sends a 6-digit OTP code — NOT a magic link
  Future<void> _sendEmailSignupOtp(String email) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        emailRedirectTo: null, // ✅ null = send OTP code, not magic link
      );
      _status = AuthStatus.otpSent;
      _errorMessage = null;
      _errorShown = false;
      notifyListeners();
      debugPrint('📧 Email OTP sent to: $email');
    } on AuthException catch (e) {
      _isInOtpFlow = false;
      debugPrint('❌ Email OTP send error: ${e.message}');
      debugPrint('❌ Email OTP send statusCode: ${e.statusCode}');
      _setError(_mapAuthError(e.message));
    } catch (e) {
      _isInOtpFlow = false;
      debugPrint('❌ Email OTP unknown error: $e');
      _setError('Failed to send OTP. Please try again.');
    }
  }

  // ─── Resend email OTP ─────────────────────────────────────
  Future<void> resendEmailOtp() async {
    _setLoading();
    _isInOtpFlow = true;
    _errorShown = false;
    try {
      await _client.auth.signInWithOtp(
        email: _email,
        shouldCreateUser: true,
        emailRedirectTo: null, // ✅ OTP code not magic link
      );
      _status = AuthStatus.otpSent;
      _errorMessage = null;
      notifyListeners();
      debugPrint('📧 Email OTP resent to: $_email');
    } on AuthException catch (e) {
      _isInOtpFlow = false;
      debugPrint('❌ Resend email OTP error: ${e.message}');
      _setError(_mapAuthError(e.message));
    } catch (e) {
      _isInOtpFlow = false;
      debugPrint('❌ Resend email OTP unknown error: $e');
      _setError('Failed to resend OTP. Please try again.');
    }
  }

  // ─── Step 2: Verify email OTP → create account ────────────
  Future<void> verifyEmailSignupOtp(String otp) async {
    _setLoading();
    _errorShown = false;
    try {
      // ✅ Verify the email OTP
      final verifyResponse = await _client.auth.verifyOTP(
        email: _email,
        token: otp,
        type: OtpType.email, // ✅ email type for signup OTP
      );

      if (verifyResponse.session == null) {
        _setError('Verification failed. Try again.');
        return;
      }

      debugPrint('✅ Email OTP verified for: $_email');

      // ✅ OTP verified — update user metadata with name and phone
      if (_pendingFullName != null || _pendingPhone != null) {
        try {
          await _client.auth.updateUser(
            UserAttributes(
              data: {
                'full_name': _pendingFullName ?? '',
                'phone': _pendingPhone ?? '',
              },
            ),
          );
          debugPrint('✅ User metadata updated');
        } catch (e) {
          debugPrint('⚠️ Metadata update error: $e');
        }
      }

      // Clear pending data
      _pendingEmail = null;
      _pendingPassword = null;
      _pendingFullName = null;
      _pendingPhone = null;

      _isInOtpFlow = false;
      _setSuccess();
      _printUserInfo(verifyResponse.session?.user);
      AppRouter.router.refresh(); // → redirect to home
    } on AuthException catch (e) {
      debugPrint('❌ Email OTP verify error: ${e.message}');
      debugPrint('❌ Email OTP verify statusCode: ${e.statusCode}');
      _setError(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('❌ Email OTP verify unknown error: $e');
      _setError('Invalid OTP. Please try again.');
    }
  }

  // ─── Send Phone OTP ───────────────────────────────────────
  // Future<void> _sendPhoneOtp(String phone) async {
  //   try {
  //     await _client.auth.signInWithOtp(phone: phone);
  //     _status = AuthStatus.otpSent;
  //     _errorMessage = null;
  //     _errorShown = false;
  //     notifyListeners();
  //     debugPrint('📱 OTP sent to: $phone');
  //   } on AuthException catch (e) {
  //     _isInOtpFlow = false;
  //     debugPrint('❌ OTP send error: ${e.message}');
  //     debugPrint('❌ OTP send statusCode: ${e.statusCode}');
  //     _setError(_mapAuthError(e.message));
  //   } catch (e) {
  //     _isInOtpFlow = false;
  //     debugPrint('❌ OTP send unknown error: $e');
  //     _setError('Failed to send OTP. Please try again.');
  //   }
  // }

  // ─── Verify Email OTP (forgot password flow) ──────────────
  Future<void> verifyEmailOtp(String otp) async {
    _setLoading();
    _errorShown = false;
    try {
      final response = await _client.auth.verifyOTP(
        email: _email,
        token: otp,
        type: OtpType.recovery,
      );
      if (response.session != null) {
        _setSuccess();
      } else {
        _setError('Verification failed. Try again.');
      }
    } on AuthException catch (e) {
      debugPrint('❌ Recovery OTP error: ${e.message}');
      _setError(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('❌ Recovery OTP unknown error: $e');
      _setError('Invalid OTP. Please try again.');
    }
  }

  // ─── Sign In ──────────────────────────────────────────────
  Future<void> signIn({required String email, required String password}) async {
    _setLoading();
    _errorShown = false;
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        _setSuccess();
        _printUserInfo(response.session?.user);
      } else {
        _setError('Login failed');
      }
    } on AuthException catch (e) {
      debugPrint('❌ SignIn error: ${e.message}');
      _setError(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('❌ SignIn unknown error: $e');
      _setError('Unexpected error');
    }
  }

  // ─── OAuth ────────────────────────────────────────────────
  // In AuthProvider — update signInWithProvider()
  Future<void> signInWithProvider(OAuthProvider provider) async {
    _setOAuthLoading(provider);
    _errorShown = false;
    try {
      await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.flutter://login-callback',

        // ✅ Force account chooser for BOTH Google and GitHub
        queryParams: {
          'prompt': 'select_account', // Google: shows account picker
          'access_type': 'offline', // Google: ensures fresh login
        },

        // ✅ Use external browser — shows proper account selection UI
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // OAuth opens browser — status resets to idle here
      // Navigation is handled by GoRouter redirect when session arrives
      _status = AuthStatus.idle;
      _oauthProvider = null;
      notifyListeners();
    } on AuthException catch (e) {
      debugPrint('❌ OAuth error: ${e.message}');
      _setError(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('❌ OAuth unknown error: $e');
      _setError('Unexpected error during sign in');
    }
  }

  // ─── Forgot Password ──────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading();
    _email = email;
    _errorShown = false;
    try {
      await _client.auth.resetPasswordForEmail(email);
      _setSuccess();
    } on AuthException catch (e) {
      debugPrint('❌ Reset password error: ${e.message}');
      _setError(_mapAuthError(e.message));
    }
  }


  Future<void> sendPasswordResetOtp(String email) async {
    _setLoading();
    _email = email;
    _errorShown = false;
    try {
      // ✅ Supabase sends 6-digit OTP in recovery email
      await _client.auth.resetPasswordForEmail(email);
      _status = AuthStatus.otpSent;
      _errorMessage = null;
      notifyListeners();
      debugPrint('✅ Password reset OTP sent to: $email');
    } on AuthException catch (e) {
      debugPrint('❌ Password reset OTP error: ${e.message}');
      _setError(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('❌ Password reset unknown error: $e');
      _setError('Failed to send OTP. Please try again.');
    }
  }

  Future<bool> checkEmailRegistered(String email) async {
    try {
      final result = await _client.rpc(
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

  // ─── Sign Out ─────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
    _phoneNumber = '';
    _email = '';
    _oauthProvider = null;
    _isInOtpFlow = false;
    _errorShown = false;
    _pendingEmail = null;
    _pendingPassword = null;
    _pendingFullName = null;
    _pendingPhone = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void resetStatus() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    _oauthProvider = null;
    _errorShown = false;
    notifyListeners();
  }

  // ─── Print user info ──────────────────────────────────────
  void _printUserInfo(User? user) {
    if (user == null) return;
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('✅ USER SIGNED IN');
    debugPrint('   ID       : ${user.id}');
    debugPrint('   Email    : ${user.email ?? 'N/A'}');
    debugPrint('   Phone    : ${user.phone ?? 'N/A'}');
    debugPrint('   Name     : ${user.userMetadata?['full_name'] ?? 'N/A'}');
    debugPrint('   Provider : ${user.appMetadata['provider'] ?? 'N/A'}');
    debugPrint('   Created  : ${user.createdAt}');
    debugPrint('   Verified : ${user.emailConfirmedAt != null}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // ─── Helpers ──────────────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _oauthProvider = null;
    _errorShown = false;
    notifyListeners();
  }

  void _setOAuthLoading(OAuthProvider provider) {
    _status = AuthStatus.oauthLoading;
    _oauthProvider = provider;
    _errorMessage = null;
    _errorShown = false;
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    _oauthProvider = null;
    _errorMessage = null;
    _errorShown = false;
    notifyListeners();
  }

  void _setError(String message) {
    if (_errorShown) return;
    _errorShown = true;
    _status = AuthStatus.error;
    _oauthProvider = null;
    _errorMessage = message;
    notifyListeners();
  }

  String _mapAuthError(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('rate limit') || msg.contains('email rate limit')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'An account with this email already exists. Please sign in.';
    }
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (msg.contains('token has expired') || msg.contains('otp expired')) {
      return 'The OTP has expired. Please request a new one.';
    }
    if (msg.contains('invalid otp') || msg.contains('token is invalid')) {
      return 'Invalid OTP. Please check and try again.';
    }
    if (msg.contains('phone') && msg.contains('invalid')) {
      return 'Invalid phone number. Please check and try again.';
    }
    if (msg.contains('password') && msg.contains('short')) {
      return 'Password must be at least 8 characters.';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return 'Network error. Please check your connection.';
    }
    if (msg.contains('user not found')) {
      return 'No account found with this email.';
    }
    return raw.isNotEmpty
        ? '${raw[0].toUpperCase()}${raw.substring(1)}'
        : 'Something went wrong. Please try again.';
  }
}
