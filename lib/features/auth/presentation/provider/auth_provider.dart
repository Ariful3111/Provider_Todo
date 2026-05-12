import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus {
  idle,
  loading,
  oauthLoading,
  success,
  otpSent,
  error,
}

class AuthProvider extends ChangeNotifier {
  final SupabaseClient client;

  AuthProvider(this.client);

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;

  bool _errorShown = false;
  bool _isInOtpFlow = false;
  bool _isPasswordRecovery = false;

  OAuthProvider? _oauthProvider;

  // Shared state
  String _email = '';
  String _phoneNumber = '';

  // Getters
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get email => _email;
  String get phoneNumber => _phoneNumber;

  bool get isPasswordRecovery => _isPasswordRecovery;

  bool get isEmailLoading => _status == AuthStatus.loading;

  bool get isOAuthLoading =>
      _status == AuthStatus.oauthLoading;

  OAuthProvider? get loadingOAuthProvider =>
      _oauthProvider;

  bool isProviderLoading(OAuthProvider provider) =>
      isOAuthLoading && _oauthProvider == provider;
  // Shared setters
  void setEmail(String email) {
    _email = email;
  }

  void setPhone(String phone) {
    _phoneNumber = phone;
  }

  void setOtpFlow(bool value) {
    _isInOtpFlow = value;
  }

  bool get isInOtpFlow => _isInOtpFlow;

  void setPasswordRecovery(bool value) {
    _isPasswordRecovery = value;
  }

  // ─────────────────────────────────────
  // State handlers
  // ─────────────────────────────────────

  void setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _oauthProvider = null;
    _errorShown = false;
    notifyListeners();
  }

  void setOAuthLoading(OAuthProvider provider) {
    _status = AuthStatus.oauthLoading;
    _oauthProvider = provider;
    _errorMessage = null;
    _errorShown = false;
    notifyListeners();
  }

  void setSuccess() {
    _status = AuthStatus.success;
    _oauthProvider = null;
    _errorMessage = null;
    _errorShown = false;
    notifyListeners();
  }

  void setError(String message) {
    if (_errorShown) return;

    _errorShown = true;

    _status = AuthStatus.error;
    _oauthProvider = null;
    _errorMessage = message;

    notifyListeners();
  }

  void resetStatus() {
    _status = AuthStatus.idle;
    _oauthProvider = null;
    _errorMessage = null;
    _errorShown = false;
    notifyListeners();
  }

  void clearAuthState() {
  _phoneNumber = '';
  _email = '';
  _oauthProvider = null;
  _isInOtpFlow = false;
  _isPasswordRecovery = false;
  _errorShown = false;

  _status = AuthStatus.idle;
  _errorMessage = null;

  notifyListeners();
}

  // ─────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────

  void printUserInfo(User? user) {
    if (user == null) return;

    debugPrint('━━━━━━━━━━━━━━━━━━━━');
    debugPrint('✅ USER SIGNED IN');
    debugPrint('ID: ${user.id}');
    debugPrint('Email: ${user.email}');
    debugPrint('Phone: ${user.phone}');
    debugPrint(
      'Name: ${user.userMetadata?['full_name']}',
    );
    debugPrint(
      'Provider: ${user.appMetadata['provider']}',
    );
    debugPrint('━━━━━━━━━━━━━━━━━━━━');
  }

  String mapAuthError(String raw) {
    final msg = raw.toLowerCase();

    if (msg.contains('rate limit')) {
      return 'Too many attempts. Please wait and try again.';
    }

    if (msg.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }

    if (msg.contains('invalid otp')) {
      return 'Invalid OTP.';
    }

    if (msg.contains('otp expired')) {
      return 'OTP expired.';
    }

    if (msg.contains('user already registered')) {
      return 'Account already exists.';
    }

    return raw.isNotEmpty
        ? '${raw[0].toUpperCase()}${raw.substring(1)}'
        : 'Something went wrong.';
  }
}

// Future<void> _sendPhoneOtp(String phone) async { // try { // await _client.auth.signInWithOtp(phone: phone); // _status = AuthStatus.otpSent; // _errorMessage = null; // _errorShown = false; // notifyListeners(); // debugPrint('📱 OTP sent to: $phone'); // } on AuthException catch (e) { // _isInOtpFlow = false; // debugPrint('❌ OTP send error: ${e.message}'); // debugPrint('❌ OTP send statusCode: ${e.statusCode}'); // _setError(_mapAuthError(e.message)); // } catch (e) { // _isInOtpFlow = false; // debugPrint('❌ OTP send unknown error: $e'); // _setError('Failed to send OTP. Please try again.'); // } // }