import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'auth_repository.dart';
import 'demo_auth_repository.dart';

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
    _repository = repository;
    _isDemoMode = isDemoMode;
    currentProfileNotifier.value = _repository.currentUserProfile;

    _authSubscription = _repository.authStateChanges.listen((profile) {
      currentProfileNotifier.value = profile;
      errorNotifier.value = null;
    });
  }

  /// Send Phone OTP
  Future<bool> sendPhoneOtp(String phone) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      await _repository.sendPhoneOtp(phone);
      isLoadingNotifier.value = false;
      return true;
    } catch (e) {
      isLoadingNotifier.value = false;
      errorNotifier.value = e.toString().replaceAll('Exception: ', '');
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
      errorNotifier.value = e.toString().replaceAll('Exception: ', '');
      return null;
    }
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
      errorNotifier.value = e.toString().replaceAll('Exception: ', '');
      return null;
    }
  }

  /// Sign In in Demo Mode with Specific Role
  Future<UserProfile?> signInDemo(UserRole role) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      final profile = await _repository.signInDemo(role);
      isLoadingNotifier.value = false;
      if (profile != null) {
        currentProfileNotifier.value = profile;
      }
      return profile;
    } catch (e) {
      isLoadingNotifier.value = false;
      errorNotifier.value = e.toString().replaceAll('Exception: ', '');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    isLoadingNotifier.value = true;
    try {
      await _repository.signOut();
      currentProfileNotifier.value = null;
      errorNotifier.value = null;
    } finally {
      isLoadingNotifier.value = false;
    }
  }
}
