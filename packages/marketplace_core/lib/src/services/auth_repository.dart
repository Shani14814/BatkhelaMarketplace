import 'dart:async';
import '../models/user_profile.dart';

/// Abstract Authentication Repository Interface
abstract class AuthRepository {
  /// Stream of user profile changes when auth state transitions
  Stream<UserProfile?> get authStateChanges;

  /// Current cached user profile if logged in
  UserProfile? get currentUserProfile;

  /// Whether a user session is active
  bool get isAuthenticated;

  /// Send Phone OTP (SMS)
  Future<void> sendPhoneOtp(String phone);

  /// Verify Phone OTP
  Future<UserProfile?> verifyPhoneOtp({
    required String phone,
    required String token,
  });

  /// Sign in with Email & Password
  Future<UserProfile?> signInWithPassword({
    required String email,
    required String password,
  });

  /// Sign in with predefined Demo Role
  Future<UserProfile?> signInDemo(UserRole role);

  /// Sign out current session
  Future<void> signOut();

  /// Fetch or refresh current user profile
  Future<UserProfile?> getCurrentUserProfile();
}
