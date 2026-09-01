import 'dart:async';
import '../models/user_profile.dart';
import 'auth_repository.dart';

/// In-Memory Demo Authentication Repository for testing and preview modes
class DemoAuthRepository implements AuthRepository {
  UserProfile? _currentProfile;
  final StreamController<UserProfile?> _authStateController =
      StreamController<UserProfile?>.broadcast();

  DemoAuthRepository({UserProfile? initialProfile})
      : _currentProfile = initialProfile;

  @override
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  @override
  UserProfile? get currentUserProfile => _currentProfile;

  @override
  bool get isAuthenticated => _currentProfile != null;

  @override
  Future<void> sendPhoneOtp(String phone) async {
    // In demo mode, simulated OTP send succeeds immediately
  }

  @override
  Future<UserProfile?> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    // Default demo customer profile on phone login
    _currentProfile = UserProfile(
      id: 'demo-user-${phone.replaceAll(RegExp(r'\D'), '')}',
      phone: phone,
      fullName: 'Batkhela Customer',
      role: UserRole.customer,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _authStateController.add(_currentProfile);
    return _currentProfile;
  }

  @override
  Future<UserProfile?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final role = email.contains('admin')
        ? UserRole.superAdmin
        : email.contains('vendor')
            ? UserRole.vendor
            : email.contains('rider')
                ? UserRole.rider
                : UserRole.customer;

    _currentProfile = UserProfile(
      id: 'demo-user-${email.split('@').first}',
      phone: '+92 345 0000000',
      fullName: email.split('@').first.toUpperCase(),
      role: role,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _authStateController.add(_currentProfile);
    return _currentProfile;
  }

  @override
  Future<UserProfile?> signInDemo(UserRole role) async {
    String name;
    String phone;

    switch (role) {
      case UserRole.vendor:
        name = 'Khyber Shinwari Store Owner';
        phone = '+92 345 2222222';
        break;
      case UserRole.rider:
        name = 'Salman Khan (Rider)';
        phone = '+92 345 3333333';
        break;
      case UserRole.admin:
      case UserRole.superAdmin:
        name = 'Super Admin';
        phone = '+92 345 9999999';
        break;
      case UserRole.customer:
        name = 'Batkhela Customer';
        phone = '+92 345 1111111';
        break;
    }

    _currentProfile = UserProfile(
      id: 'demo-role-${role.toDbString()}',
      phone: phone,
      fullName: name,
      role: role,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _authStateController.add(_currentProfile);
    return _currentProfile;
  }

  @override
  Future<void> signOut() async {
    _currentProfile = null;
    _authStateController.add(null);
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    return _currentProfile;
  }

  void dispose() {
    _authStateController.close();
  }
}
