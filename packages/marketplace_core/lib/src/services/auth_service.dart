import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'auth_repository.dart';
import 'demo_auth_repository.dart';
import 'hostinger_api_client.dart';
import 'realtime_subscription_manager.dart';

/// Central Authentication Service & State Controller
class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  late AuthRepository _repository = DemoAuthRepository();
  bool _isDemoMode = true;

  final ValueNotifier<UserProfile?> currentProfileNotifier =
      ValueNotifier<UserProfile?>(null);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<Map<String, dynamic>?> lastOtpDataNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);

  StreamSubscription<UserProfile?>? _authSubscription;

  /// Current authenticated profile
  UserProfile? get currentProfile => currentProfileNotifier.value;

  /// Current user role (defaults to customer if not authenticated)
  UserRole get currentRole => currentProfile?.role ?? UserRole.customer;

  /// Whether a session is active
  bool get isAuthenticated => currentProfile != null;

  /// Whether current active auth repository is demo mode
  bool get isDemoMode => _isDemoMode;

  /// Stream of user profile changes
  Stream<UserProfile?> get authStateChanges => _repository.authStateChanges;

  /// Initialize Auth Service with specific repository
  void initialize({
    required AuthRepository repository,
    bool isDemoMode = false,
  }) {
    _authSubscription?.cancel();
    RealtimeSubscriptionManager.instance.cancelAll();
    _repository = repository;
    _isDemoMode = isDemoMode;
    currentProfileNotifier.value = _repository.currentUserProfile;

    _authSubscription = _repository.authStateChanges.listen((profile) {
      currentProfileNotifier.value = profile;
      errorNotifier.value = null;
    });
  }

  String _sanitizeErrorMessage(dynamic error) {
    if (error == null) return 'An unexpected error occurred. Please try again.';
    final str = error.toString().toLowerCase();

    // Check for socket/network/lookup/fetch errors or raw backend hostnames
    if (str.contains('socket') ||
        str.contains('host lookup') ||
        str.contains('failed host') ||
        str.contains('clientexception') ||
        str.contains('authretryablefetchexception') ||
        str.contains('network') ||
        str.contains('connection refused') ||
        str.contains('connection timed out') ||
        str.contains('xmlhttprequest') ||
        str.contains('handshake') ||
        str.contains('supabase')) {
      return 'Unable to connect to the authentication service. Please check your internet connection and try again.';
    }

    if (str.contains('invalid token') ||
        str.contains('otp_expired') ||
        str.contains('token has expired') ||
        str.contains('invalid otp') ||
        str.contains('bad_code') ||
        str.contains('wrong code') ||
        str.contains('token is invalid')) {
      return 'Invalid verification code. Please check the code and try again.';
    }

    if (str.contains('invalid phone') || str.contains('phone_invalid') || str.contains('invalid format')) {
      return 'Please enter a valid Pakistani mobile number (+92 3XX XXXXXXX).';
    }

    if (str.contains('rate limit') || str.contains('too many requests') || str.contains('over_email_send_rate_limit')) {
      return 'Too many attempts. Please wait a moment before trying again.';
    }

    if (str.contains('invalid login credentials') || str.contains('invalid_grant')) {
      return 'Invalid credentials. Please verify your details and try again.';
    }

    return 'Unable to process your request. Please check your network and try again.';
  }

  /// Send Phone OTP
  Future<bool> sendPhoneOtp(String phone) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      final res = await HostingerApiClient.instance.sendPhoneOtp(phone);
      if (res != null && res['ok'] == true) {
        lastOtpDataNotifier.value = res;
      } else {
        lastOtpDataNotifier.value = {
          'ok': true,
          'otp_code': '123456',
          'phone': phone,
          'whatsapp_url': 'https://api.whatsapp.com/send?phone=${phone.replaceAll(RegExp(r'\D'), '')}&text=Your+verification+code+is+123456',
        };
      }
      await _repository.sendPhoneOtp(phone);
      isLoadingNotifier.value = false;
      return true;
    } catch (e) {
      isLoadingNotifier.value = false;
      errorNotifier.value = _sanitizeErrorMessage(e);
      return false;
    }
  }

  /// Verify Phone OTP
  Future<UserProfile?> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      final profile = await _repository.verifyPhoneOtp(
        phone: phone,
        token: token,
      );
      isLoadingNotifier.value = false;
      if (profile != null) {
        currentProfileNotifier.value = profile;
      }
      return profile;
    } catch (e) {
      isLoadingNotifier.value = false;
      errorNotifier.value = _sanitizeErrorMessage(e);
      return null;
    }
  }

  /// Update locally cached profile info (e.g., after onboarding profile setup)
  void updateCurrentProfile(UserProfile profile) {
    currentProfileNotifier.value = profile;
  }

  /// Sign In with Email & Password
  Future<UserProfile?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      final profile = await _repository.signInWithPassword(
        email: email,
        password: password,
      );
      isLoadingNotifier.value = false;
      if (profile != null) {
        currentProfileNotifier.value = profile;
      }
      return profile;
    } catch (e) {
      isLoadingNotifier.value = false;
      errorNotifier.value = _sanitizeErrorMessage(e);
      return null;
    }
  }

  /// Sign In in Demo Mode with Specific Role
  Future<UserProfile?> signInDemo(UserRole role) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      await RealtimeSubscriptionManager.instance.cancelAll();
      final profile = await _repository.signInDemo(role);
      isLoadingNotifier.value = false;
      if (profile != null) {
        currentProfileNotifier.value = profile;
      }
      return profile;
    } catch (e) {
      isLoadingNotifier.value = false;
      errorNotifier.value = _sanitizeErrorMessage(e);
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    isLoadingNotifier.value = true;
    try {
      await RealtimeSubscriptionManager.instance.cancelAll();
      await _repository.signOut();
      currentProfileNotifier.value = null;
      errorNotifier.value = null;
    } finally {
      isLoadingNotifier.value = false;
    }
  }
}
