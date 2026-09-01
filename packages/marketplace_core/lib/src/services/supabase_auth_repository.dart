import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'auth_repository.dart';

/// Real Supabase Authentication Repository Implementation
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;
  UserProfile? _cachedProfile;
  final StreamController<UserProfile?> _authStateController =
      StreamController<UserProfile?>.broadcast();

  SupabaseAuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client {
    _initListener();
  }

  void _initListener() {
    _client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        final profile = await getCurrentUserProfile();
        _cachedProfile = profile;
        _authStateController.add(profile);
      } else {
        _cachedProfile = null;
        _authStateController.add(null);
      }
    });
  }

  @override
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  @override
  UserProfile? get currentUserProfile => _cachedProfile;

  @override
  bool get isAuthenticated => _client.auth.currentUser != null;

  @override
  Future<void> sendPhoneOtp(String phone) async {
    await _client.auth.signInWithOtp(
      phone: phone,
    );
  }

  @override
  Future<UserProfile?> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final response = await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );

    if (response.user != null) {
      _cachedProfile = await getCurrentUserProfile();
      _authStateController.add(_cachedProfile);
      return _cachedProfile;
    }
    return null;
  }

  @override
  Future<UserProfile?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      _cachedProfile = await getCurrentUserProfile();
      _authStateController.add(_cachedProfile);
      return _cachedProfile;
    }
    return null;
  }

  @override
  Future<UserProfile?> signInDemo(UserRole role) async {
    // SupabaseAuthRepository delegates to mock/profile lookup if needed
    throw UnimplementedError('Demo sign in is only available in DemoAuthRepository');
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    _cachedProfile = null;
    _authStateController.add(null);
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        // Fallback profile if database trigger is slightly delayed
        return UserProfile(
          id: user.id,
          phone: user.phone ?? '',
          fullName: (user.userMetadata?['full_name'] as String?) ?? 'Marketplace User',
          avatarUrl: user.userMetadata?['avatar_url'] as String?,
          role: UserRole.customer,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
